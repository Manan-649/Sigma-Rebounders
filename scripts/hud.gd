class_name HUD
extends CanvasLayer

const THEME_PATH := "res://ui/theme.tres"
const STAR_FILLED := "res://ui/star_filled.png"
const STAR_EMPTY := "res://ui/star_empty.png"

@onready var root: Control = $Root
@onready var level_label: Label = $Root/TopBar/HBox/LevelLabel
@onready var shots_label: Label = $Root/TopBar/HBox/ShotsLabel
@onready var bounces_label: Label = $Root/TopBar/HBox/BouncesLabel
@onready var pause_button: Button = $Root/TopBar/HBox/PauseButton
@onready var restart_button: Button = $Root/TopBar/HBox/RestartButton
@onready var toast: Label = $Root/Toast
@onready var dim: ColorRect = $Root/Dim
@onready var win_panel: PanelContainer = $Root/WinPanel
@onready var stars: Array[TextureRect] = [
	$Root/WinPanel/VBox/Stars/Star1,
	$Root/WinPanel/VBox/Stars/Star2,
	$Root/WinPanel/VBox/Stars/Star3,
]
@onready var win_shots: Label = $Root/WinPanel/VBox/ShotsText
@onready var retry_button: Button = $Root/WinPanel/VBox/Buttons/RetryButton
@onready var next_button: Button = $Root/WinPanel/VBox/Buttons/NextButton
@onready var pause_panel: PanelContainer = $Root/PausePanel
@onready var resume_button: Button = $Root/PausePanel/VBox/ResumeButton
@onready var pause_restart_button: Button = $Root/PausePanel/VBox/PauseRestartButton

var max_bounces := 0
var has_won := false
var _toast_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if ResourceLoader.exists(THEME_PATH):
		root.theme = load(THEME_PATH)
	else:
		var t := Theme.new()
		t.default_font_size = 28
		root.theme = t

	toast.add_theme_font_size_override("font_size", 56)
	toast.modulate.a = 0.0

	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ignore_mouse(root)

	dim.hide()
	win_panel.hide()
	pause_panel.hide()

	restart_button.pressed.connect(Game.restart_level)
	pause_button.pressed.connect(toggle_pause)
	retry_button.pressed.connect(Game.restart_level)
	next_button.pressed.connect(_on_next_pressed)
	resume_button.pressed.connect(toggle_pause)
	pause_restart_button.pressed.connect(Game.restart_level)


func setup(level: Level) -> void:
	max_bounces = level.max_bounces
	level_label.text = "Level %d" % (Game.current_level + 1)
	next_button.visible = not Game.is_last_level()
	_set_shots(0)
	_set_bounces(max_bounces)

	level.launcher.shot_fired.connect(_on_shot_fired)
	level.launcher.ball.bounced.connect(_on_ball_bounced)
	level.attempt_failed.connect(_on_attempt_failed)
	level.won.connect(_on_won)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not has_won:
		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	dim.visible = paused
	pause_panel.visible = paused
	if paused:
		_pop_in(pause_panel)


func _on_shot_fired(shots: int) -> void:
	_set_shots(shots)
	_set_bounces(max_bounces)


func _on_ball_bounced(_wall: Node, _point: Vector2, bounces_left: int) -> void:
	_set_bounces(bounces_left)


func _on_attempt_failed(targets_left: int) -> void:
	_set_bounces(max_bounces)
	show_toast("Bounce back! %d left" % targets_left)


func _on_won(shots: int, star_count: int) -> void:
	has_won = true
	pause_button.disabled = true
	await get_tree().create_timer(0.6).timeout

	win_shots.text = "Shots: %d" % shots
	for s in stars:
		s.texture = _tex(STAR_EMPTY)
	dim.show()
	win_panel.show()
	_pop_in(win_panel)

	for i in star_count:
		await get_tree().create_timer(0.3).timeout
		stars[i].texture = _tex(STAR_FILLED)
		_pop_in(stars[i])


func _on_next_pressed() -> void:
	Game.load_level(Game.current_level + 1)


func _set_shots(n: int) -> void:
	shots_label.text = "Shots: %d" % n


func _set_bounces(n: int) -> void:
	bounces_label.text = "Bounces: %d" % n


func show_toast(text: String) -> void:
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	toast.text = text
	toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.2)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.4)


func _pop_in(node: Control) -> void:
	await get_tree().process_frame
	node.pivot_offset = node.size / 2.0
	node.scale = Vector2(0.6, 0.6)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2.ONE, 0.25)


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return preload("res://icon.svg")


func _ignore_mouse(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton:
			continue
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(child)
