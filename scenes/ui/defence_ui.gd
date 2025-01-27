class_name DefenceUI
extends HBoxContainer

@onready var block_status = $VBoxContainer/BlockStatus
@onready var question_status = $VBoxContainer2/QuestionStatus

# Paths to the icon textures
var tick_icon = preload("res://kenney_roguelike-characters/Spritesheet/tick.png")
var cross_icon = preload("res://kenney_roguelike-characters/Spritesheet/cross.png")
var hourglass_icon = preload("res://kenney_roguelike-characters/Spritesheet/hourglass.png")

func reset_ui():
	# Hide the DefenceUI at the start or after the enemy attacks
	visible = false
	block_status.texture = null
	question_status.texture = null

func show_defense_ui():
	# Show the DefenceUI when a defense card is played
	visible = true
	block_status.texture = null
	question_status.texture = hourglass_icon
	block_status.texture = hourglass_icon

func update_block_status(correct: bool):
	# Update the block status based on whether the defense card was correct
	block_status.texture = tick_icon if correct else cross_icon

func update_question_status(correct: bool):
	# Update the question status based on whether the player answered correctly
	question_status.texture = tick_icon if correct else cross_icon
