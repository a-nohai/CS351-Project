class_name Map
extends Control

func _on_button_pressed(extra_arg_0: String) -> void:
	Events.map_exited.emit(extra_arg_0)

func show_map() -> void:
	show()

func hide_map() -> void:
	hide()
