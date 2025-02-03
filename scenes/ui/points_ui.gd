class_name PointsUI
extends Panel

@export var points: int

@onready var points_label: Label = $PointsLabel


func set_points(curr_points: int) -> void:
	points = curr_points
	points_label.text = "Points: %s" % [points]
	
	#if not Events.points_changed.is_connected(_on_points_changed):
		#Events.points_changed.connect(_on_points_changed)
#
	#if not is_node_ready():
		#await ready
#
	#_on_points_changed()
#
#
#func _on_points_changed() -> void:
	#points_label.text = "Points: %s" % [points]
