extends Node

const LAYER_BALL := 1
const LAYER_WALLS := 2
const LAYER_TARGETS := 3

const LEVELS_DIR := "res://scenes/levels/"

var levels: Array[String] = []
var current_level := 0


func _ready() -> void:
	for file in ResourceLoader.list_directory(LEVELS_DIR):
		if file.begins_with("level_") and file.ends_with(".tscn"):
			levels.append(LEVELS_DIR + file)
	levels.sort()
	print("Levels found: ", levels)


func load_level(index: int) -> void:
	get_tree().paused = false
	current_level = clampi(index, 0, levels.size() - 1)
	get_tree().change_scene_to_file(levels[current_level])


func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func set_current_from_path(path: String) -> void:
	var i := levels.find(path)
	if i != -1:
		current_level = i


func is_last_level() -> bool:
	return current_level >= levels.size() - 1
