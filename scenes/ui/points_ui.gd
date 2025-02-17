class_name PointsUI
extends Panel

@export var points: int

@onready var points_label: Label = $PointsLabel


func set_points(curr_points: int) -> void:
	points = curr_points
	points_label.text = "Points: %s" % [points]
