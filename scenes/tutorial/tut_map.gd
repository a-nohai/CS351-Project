class_name TutorialMap
extends Control

@onready var tutorial_button: Button = %TutorialButton

func _on_button_pressed() -> void:
	Events.tutorial_map_exited.emit()

func show_map() -> void:
	show()

func hide_map() -> void:
	hide()
