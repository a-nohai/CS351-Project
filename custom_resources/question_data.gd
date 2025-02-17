class_name QuestionData
extends Resource

@export var questions: Dictionary = {}

func set_values(question, answers) -> void:
	questions[question] = answers
