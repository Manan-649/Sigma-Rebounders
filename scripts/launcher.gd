class_name Launcher
extends Node2D

signal shot_fired(shots: int)
signal ball_lost

const BALL_SCENE := preload("res://scenes/game/ball.tscn")
const BALL_RADIUS := 15.0
const MUZZLE := 40.0
const PREVIEW_RANGE := 3000.0

@export var max_bounces := 5
@export var min_speed := 400.0
@export var max_speed := 1100.0
@export var max_drag := 200.0
@export var min_drag := 20.0
@export var bounce_preview := 120.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var aim_line: Line2D = $AimLine

var ball: Ball
var aiming := false
var drag_start := Vector2.ZERO
var shots := 0
var _circle := CircleShape2D.new()


func _ready() -> void:
	_circle.radius = BALL_RADIUS
	ball = BALL_SCENE.instantiate()
	ball.top_level = true
	add_child(ball)
	ball.hide()
	ball.died.connect(_on_ball_died)
	aim_line.top_level = true


func _unhandled_input(event: InputEvent) -> void:
	if ball.active:
		return

	if event.is_action_pressed("launch"):
		aiming = true
		drag_start = get_global_mouse_position()
		get_viewport().set_input_as_handled()

	elif event.is_action_released("launch") and aiming:
		aiming = false
		aim_line.clear_points()
		var drag := drag_start - get_global_mouse_position()
		if drag.length() >= min_drag:
			_fire(drag)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not aiming:
		return
	var drag := drag_start - get_global_mouse_position()
	if drag.length() < min_drag:
		aim_line.clear_points()
		return
	var dir := drag.normalized()
	sprite.rotation = dir.angle()
	_update_preview(dir)


func _fire(drag: Vector2) -> void:
	var power := clampf(drag.length() / max_drag, 0.0, 1.0)
	var speed := lerpf(min_speed, max_speed, power)
	var dir := drag.normalized()
	ball.launch(global_position + dir * MUZZLE, dir * speed, max_bounces)
	shots += 1
	shot_fired.emit(shots)


func _update_preview(dir: Vector2) -> void:
	var start := global_position + dir * MUZZLE
	var space := get_world_2d().direct_space_state

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _circle
	query.transform = Transform2D(0.0, start)
	query.motion = dir * PREVIEW_RANGE
	query.collision_mask = 1 << (Game.LAYER_WALLS - 1)

	var result := space.cast_motion(query)
	var hit_pos := start + query.motion * result[0]

	aim_line.clear_points()
	aim_line.add_point(start)
	aim_line.add_point(hit_pos)

	if result[1] >= 1.0:
		return

	query.transform = Transform2D(0.0, start + query.motion * result[1])
	query.motion = Vector2.ZERO
	var info := space.get_rest_info(query)
	if info.is_empty():
		return

	var bounce_dir := dir.bounce(info["normal"])
	aim_line.add_point(hit_pos + bounce_dir * bounce_preview)


func _on_ball_died() -> void:
	ball_lost.emit()
