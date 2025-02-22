class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE, FINAL}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	continue_button.pressed.connect(func(): Events.battle_won.emit())
	restart_button.pressed.connect(func(): Events.battle_lost.emit())
	quit_button.pressed.connect(get_tree().quit)
	Events.battle_over_screen_requested.connect(show_screen)


func show_screen(text: String, type: Type) -> void:    
	label.text = text
	continue_button.visible = type == Type.WIN
	restart_button.visible = type == Type.LOSE
	quit_button.visible = type == Type.FINAL
	show()
	get_tree().paused = true
