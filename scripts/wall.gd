@tool
class_name Wall
extends StaticBody2D

enum Type { NORMAL, BOUNCY, STICKY }

const GRID := 32.0
const PATCH_MARGIN := 10

const ART := {
	Type.NORMAL: "res://sprites/wall.png",
	Type.BOUNCY: "res://sprites/wall_bouncy.png",
	Type.STICKY: "res://sprites/wall_sticky.png",
}

const TINT := {
	Type.NORMAL: Color.WHITE,
	Type.BOUNCY: Color("3ddc84"),
	Type.STICKY: Color("e5534b"),
}

const PLACEHOLDER := {
	Type.NORMAL: Color("8a8fa3"),
	Type.BOUNCY: Color("3ddc84"),
	Type.STICKY: Color("e5534b"),
}

@export var type: Type = Type.NORMAL:
	set(value):
		type = value
		_refresh()

@export var size := Vector2(128, 32):
	set(value):
		size = Vector2(
			maxf(GRID, snappedf(value.x, GRID)),
			maxf(GRID, snappedf(value.y, GRID)))
		_refresh()

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _placeholder: ColorRect = $Placeholder
@onready var _art: NinePatchRect = $Art


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(2, true)

	_shape.shape = RectangleShape2D.new()

	_art.patch_margin_left = PATCH_MARGIN
	_art.patch_margin_top = PATCH_MARGIN
	_art.patch_margin_right = PATCH_MARGIN
	_art.patch_margin_bottom = PATCH_MARGIN

	_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_refresh()
	print(name, " | layer ", collision_layer, " | shape ", (_shape.shape as RectangleShape2D).size)


func _refresh() -> void:
	if not is_node_ready():
		return

	(_shape.shape as RectangleShape2D).size = size
	for rect in [_placeholder, _art]:
		rect.position = -size / 2.0
		rect.size = size

	var tex: Texture2D = null
	var tint := Color.WHITE
	if ResourceLoader.exists(ART[type]):
		tex = load(ART[type])
	elif ResourceLoader.exists(ART[Type.NORMAL]):
		tex = load(ART[Type.NORMAL])
		tint = TINT[type]

	_art.texture = tex
	_art.modulate = tint
	_art.visible = tex != null
	_placeholder.visible = tex == null
	_placeholder.color = PLACEHOLDER[type]
