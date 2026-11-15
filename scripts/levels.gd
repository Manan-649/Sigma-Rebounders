class_name Level
extends Node2D

signal won(shots: int, stars: int)
signal attempt_failed(targets_left: int)

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

@export_range(3, 6) var max_bounces := 4
@export var shots_for_3_stars := 1
@export var shots_for_2_stars := 2

@onready var launcher: Launcher = $Launcher

var targets_left := 0
var has_won := false
var hud: HUD


func _ready() -> void:
	launcher.max_bounces = max_bounces
	launcher.ball_lost.connect(_on_ball_lost)

	for t in get_tree().get_nodes_in_group("targets"):
		targets_left += 1
		t.hit.connect(_on_target_hit)

	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.setup(self)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		Game.restart_level()


func _on_target_hit(_target: Target) -> void:
	targets_left -= 1
	if targets_left == 0:
		_win()


func _on_ball_lost() -> void:
	if has_won:
		return
	attempt_failed.emit(targets_left)


func _win() -> void:
	has_won = true
	launcher.set_process_unhandled_input(false)
	launcher.ball.die()

	var shots := launcher.shots
	var stars := 1
	if shots <= shots_for_3_stars:
		stars = 3
	elif shots <= shots_for_2_stars:
		stars = 2

	won.emit(shots, stars)
