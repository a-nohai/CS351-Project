class_name MCQHandler
extends Node

# Store the loaded questions
var questions_data = {}

func _ready() -> void:
	load_questions()

# Load the JSON file containing the questions
func load_questions() -> void:
	var file = FileAccess.open("res://questions.json", FileAccess.READ)
	if file:
		var json_parser = JSON.new()
		var result = json_parser.parse(file.get_as_text())
		questions_data = json_parser.data
		file.close()
		print("Questions loaded successfully.")
	else:
		print("Failed to load questions.json")

# Get questions for a specific OSI layer
func get_questions_for_layer(layer: String) -> Array:
	for entry in questions_data:
		if entry.layer == layer:
			return entry.questionset
	return []

# Get a random question from a specific OSI layer
func get_random_question(layer: String) -> Dictionary:
	var questions = get_questions_for_layer(layer)
	return questions[randi() % questions.size()] if questions.size() > 0 else null

# Trigger an MCQ for a specific layer
func trigger_question(layer: String) -> void:
	var question_data = get_random_question(layer)
	if question_data:
		var question_text = question_data.question
		var answers = question_data.answers
		var correct_index = answers.find(question_data.correct_option)
		Events.mcq_screen_requested.emit(question_text, correct_index, answers)
