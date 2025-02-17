class_name MCQPanel
extends Panel

@onready var answer1: Button = %Answer1
@onready var answer2: Button = %Answer2
@onready var answer3: Button = %Answer3
@onready var answer4: Button = %Answer4
@onready var question: Question = %Question

@export var wrong_answers: QuestionData

var correct_answer: int
var correct_text: String

func _ready() -> void:
	# Connect the MCQ screen signal
	Events.mcq_screen_requested.connect(show_screen)

	# Connect button signals using a loop
	var buttons = [answer1, answer2, answer3, answer4]
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_answer_selected.bind(i))

func show_screen(text: String, correct: int, options: Array):
	question.show_question(text)
	correct_text = options[0]
	# Shuffle the options and update the correct index
	var shuffled_answers = []
	var new_correct_index = -1

	# Create an array of indices and shuffle them
	var indices = []
	for i in range(options.size()):
		indices.append(i)
	indices.shuffle()

	# Reorder the options based on shuffled indices
	for i in range(options.size()):
		shuffled_answers.append(options[indices[i]])
		if indices[i] == correct:
			new_correct_index = i

	# Assign the shuffled answers to the buttons
	var button_paths = [
		"VBoxContainer/VBoxContainer/HBoxContainer2/Answer1",
		"VBoxContainer/VBoxContainer/HBoxContainer2/Answer2",
		"VBoxContainer/VBoxContainer/HBoxContainer/Answer3",
		"VBoxContainer/VBoxContainer/HBoxContainer/Answer4"
	]

	for i in range(shuffled_answers.size()):
		var button = get_node(button_paths[i])
		if button:
			button.text = shuffled_answers[i]
		else:
			print("Node not found: {}".format(button_paths[i]))

	# Update the correct answer
	correct_answer = new_correct_index

	# Show the question panel
	show()
	get_tree().paused = true



func _on_answer_selected(answer_index: int):
	hide()
	get_tree().paused = false
	if answer_index != correct_answer:
		wrong_answers.questions[question.get_text()] = correct_text
		print("wrong answer here")
		print(wrong_answers.questions)
	Events.mcq_answered.emit(answer_index == correct_answer)
