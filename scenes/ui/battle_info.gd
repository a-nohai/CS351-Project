class_name BattleInfo
extends PanelContainer

@onready var layer_label: Label = $MarginContainer/HBoxContainer/Label
@onready var turn_label: Label = $MarginContainer/HBoxContainer/Label2


func _ready() -> void:
	pass

func set_layer(curr_layer: String) -> void:
	layer_label.text = curr_layer + "\nLayer"

func set_turn(curr_turn: String) -> void:
	turn_label.text = curr_turn + "\nTurn"
