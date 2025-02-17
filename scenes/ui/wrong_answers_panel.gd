class_name WrongAnswersPanel
extends Panel

const ENTRY := preload("res://scenes/ui/incorrect_answer.tscn")

@onready var label: Label = %Label
@onready var restart_button: Button = %RestartButton
@onready var scrollable: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer


func _ready() -> void:
	restart_button.pressed.connect(func(): Events.briefing_read.emit())
	Events.battle_over_screen_requested.connect(show_screen)


func show_screen(questions: Dictionary) -> void:    
	populate_scrollable(questions)
	show()
	get_tree().paused = true

func populate_scrollable(questions: Dictionary) -> void:
	for value in questions:
		var new_entry = ENTRY.instantiate()
		
		scrollable.add_child(new_entry)
		new_entry.set_question(value, questions[value])

func depopulate_scrollable() -> void:
	for n in scrollable.get_children():
		n.queue_free()
