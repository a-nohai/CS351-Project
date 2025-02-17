extends Control

const RUN_SCENE := preload("res://scenes/run/run.tscn")
const TUTORIAL_SCENE := preload("res://scenes/tutorial/tutorial.tscn")

@onready var continue_button: Button = %Continue

@export var run_startup: RunStartup

func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null

func _on_continue_pressed() -> void:
	run_startup.type = RunStartup.Type.CONTINUED_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)

func _on_new_game_pressed() -> void:
	run_startup.type = RunStartup.Type.NEW_RUN
	get_tree().change_scene_to_packed(TUTORIAL_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
