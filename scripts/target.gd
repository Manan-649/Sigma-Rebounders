class_name Target
extends Area2D

signal hit(target: Target)

const HIT_EFFECT := "res://scenes/effects/target_hit.tscn"

var is_hit := false


func _ready() -> void:
	add_to_group("targets")
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(Game.LAYER_TARGETS, true)
	set_collision_mask_value(Game.LAYER_BALL, true)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_hit or not body is Ball:
		return
	is_hit = true
	set_deferred("monitoring", false)
	_spawn_effect()
	hit.emit(self)

	var tween := create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(hide)


func _spawn_effect() -> void:
	if not ResourceLoader.exists(HIT_EFFECT):
		return
	var fx: Node2D = load(HIT_EFFECT).instantiate()
	fx.global_position = global_position
	get_parent().add_child(fx)
