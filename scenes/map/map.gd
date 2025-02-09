class_name Map
extends Control

@onready var layer_3_button: Button = %Layer3Button
@onready var layer_4_button: Button = %Layer4Button
@onready var layer_5_button: Button = %Layer5Button
@onready var layer_6_button: Button = %Layer6Button
@onready var layer_7_button: Button = %Layer7Button
@onready var final_button: Button = %FinalButton
@onready var layer_1_points: Label = %Layer1Points
@onready var layer_2_points: Label = %Layer2Points
@onready var layer_3_points: Label = %Layer3Points
@onready var layer_4_points: Label = %Layer4Points
@onready var layer_5_points: Label = %Layer5Points
@onready var layer_6_points: Label = %Layer6Points
@onready var layer_7_points: Label = %Layer7Points
@onready var final_points: Label = %FinalPoints

func _on_button_pressed(extra_arg_0: String) -> void:
	Events.map_exited.emit(extra_arg_0)

func show_map() -> void:
	show()

func hide_map() -> void:
	hide()

func enable_button(layer: int) -> void:
	match layer:
		3:
			layer_3_points.text = "0/3 PTS"
			layer_3_button.disabled = false
		4:
			layer_4_points.text = "0/3 PTS"
			layer_4_button.disabled = false
		5:
			layer_5_points.text = "0/3 PTS"
			layer_5_button.disabled = false
		6:
			layer_6_points.text = "0/3 PTS"
			layer_6_button.disabled = false
		7:
			layer_7_points.text = "0/3 PTS"
			layer_7_button.disabled = false
		8:
			final_points.text = "UNLOCKED!"
			final_button.disabled = false

func set_layer_points(layer: String, new_points:int) -> void:
	match layer:
		"Physical":
			layer_1_points.text = "%s/3 PTS" % [new_points]
		"Data Link":
			layer_2_points.text = "%s/3 PTS" % [new_points]
		"Application":
			layer_3_points.text = "%s/3 PTS" % [new_points]
		"Network":
			layer_4_points.text = "%s/3 PTS" % [new_points]
		"Presentation":
			layer_5_points.text = "%s/3 PTS" % [new_points]
		"Session":
			layer_6_points.text = "%s/3 PTS" % [new_points]
		"Transport":
			layer_7_points.text = "%s/3 PTS" % [new_points]
