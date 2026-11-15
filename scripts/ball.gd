class_name Ball
extends CharacterBody2D
signal bounced(wall: Node, point: Vector2, bounces_left: int)  
signal died 

@export var bouncy_boost := 1.25  
@export var max_speed := 1600.0 

@export var test_launch := Vector2.ZERO
@export var test_bounces := 5

var bounces_left := 0
var active := false  


const SAFE_AREA := Rect2(-100, -100, 1480, 920)


func _ready() -> void:
	
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(Game.LAYER_BALL, true)
	set_collision_mask_value(Game.LAYER_WALLS, true)

	if test_launch != Vector2.ZERO:
		launch(global_position, test_launch, test_bounces)



func launch(from: Vector2, vel: Vector2, max_bounces: int) -> void:
	global_position = from
	velocity = vel
	bounces_left = max_bounces
	active = true
	show()


func _physics_process(delta: float) -> void:
	if not active:
		return

	
	var hit := move_and_collide(velocity * delta)

	if not SAFE_AREA.has_point(global_position):
		print("Left the screen at ", global_position) 
		die()
		return
	if hit == null:
		return

	var wall := hit.get_collider()

	
	var type := Wall.Type.NORMAL
	if wall is Wall:
		type = wall.type

	print("Hit ", wall.name, " | type ", type, " | bounces left ", bounces_left)  # debug
	if type == Wall.Type.STICKY or bounces_left <= 0:
		die()
		return

	
	velocity = velocity.bounce(hit.get_normal())
	if type == Wall.Type.BOUNCY:
		velocity = (velocity * bouncy_boost).limit_length(max_speed)

	bounces_left -= 1
	print("Bounce! Left: ", bounces_left)  # we gotta remove later
	bounced.emit(wall, hit.get_position(), bounces_left)


func die() -> void:
	if not active:
		return
	active = false
	velocity = Vector2.ZERO
	hide()
	print("Ball died")  # debug, we gotta remove it later
	died.emit()
