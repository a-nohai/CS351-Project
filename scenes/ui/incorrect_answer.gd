class_name IncorrectAnswer
extends HBoxContainer

@onready var question_label: Label = $Question
@onready var correct_ans_label: Label = $CorrectAnswer

func _ready() -> void:
	pass

func set_question(question: String, correct_ans: String) -> void:
	question_label.text = question
	correct_ans_label.text = correct_ans
