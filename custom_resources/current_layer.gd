class_name CurrentLayer
extends Resource

@export var layer: String
@export var max_points = {
	"Physical": 0,
	"Data Link": 0,
	"Application": 0,
	"Network": 0,
	"Presentation": 0,
	"Session": 0,
	"Transport": 0}

func set_max_points(points: int, curr_layer: String) -> void:
	max_points[curr_layer] = points
