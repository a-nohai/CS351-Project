class_name Question
extends PanelContainer

@onready var question_text_label: RichTextLabel = %QuestionText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func show_question(text: String) -> void:
	question_text_label.text = text

func get_text() -> String:
	return question_text_label.text
