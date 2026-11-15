extends Node
const LAYER_BALL := 1
const LAYER_WALLS := 2
const LAYER_TARGETS := 3
const LEVELS := [
	"res://scenes/test/test_level.tscn",
]

var current_level = 0
func _ready() -> void:
	print("Game autoload ready. Levels: ", LEVELS.size())
	
func load_level(index:int) -> void:
	current_level = clampi(index, 0, LEVELS.size() - 1) #clampi keeps level between 0 to last level
	get_tree().change_scene_to_file(LEVELS[current_level])

func restart_level() ->void:
	get_tree().reload_current_scene()
