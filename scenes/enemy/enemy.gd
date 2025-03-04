class_name Enemy
extends Area2D

const ARROW_OFFSET := 200
const WHITE_SPRITE_MATERIAL := preload("res://kenney_roguelike-characters/Spritesheet/white_sprite_material.tres")

@export var stats: EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI
@onready var intent_ui: IntentUI = $IntentUI as IntentUI
@onready var mcq_handler: MCQHandler = $"../../MCQHandler"
@onready var player_handler: PlayerHandler = $"../../PlayerHandler"
@onready var defence_ui = $"../../BattleUI/DefenceUI"
@onready var battle = $"../.."

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action

func set_current_action(value: EnemyAction) -> void:
	current_action = value
	if current_action:
		intent_ui.update_intent(current_action.intent)

func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
	
	update_enemy()


func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue.free()
	
	var new_action_picker: EnemyActionPicker = stats.ai.instantiate()
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self

func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action
	

func update_stats() -> void:
	stats_ui.update_stats(stats)

func update_enemy() -> void:
	if not stats is Stats: 
		return
	if not is_inside_tree(): 
		await ready
	
	sprite_2d.texture = stats.art
	arrow.position = Vector2.UP * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	setup_ai()
	update_stats()

func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	if current_action.isAttack and player_handler.played_defence:
		mcq_handler.trigger_question(battle.current_layer.layer)
		Events.mcq_answered.connect(_on_mcq_result)
	else:
		current_action.perform_action()

func _on_mcq_result(correct_mcq: bool) -> void:
	Events.mcq_answered.disconnect(_on_mcq_result)
	#player_handler.mcq_correct = correct_mcq
	# Calculate the damage based on defense and MCQ correctness
	var temp_damage = current_action.damage
	#print(player_handler.defence_type)
	#print(current_action.required_defence)
	if correct_mcq and player_handler.defence_type == current_action.required_defence:
		current_action.damage = 0
		#print("Both correct! No damage taken.")
	elif correct_mcq or player_handler.defence_type == current_action.required_defence:
		current_action.damage = (0.5 * temp_damage) + 1
		#print("One correct! Reduced damage taken.")
	else:
		#print("Both incorrect! Full damage taken.")
		current_action.damage = temp_damage + 1
	# Perform the action
	defence_ui.update_block_status(player_handler.defence_type == current_action.required_defence)
	defence_ui.update_question_status(correct_mcq)
	if current_action.damage == 0:
		defence_ui.update_damage(current_action.damage)
	else:
		defence_ui.update_damage(current_action.damage - 1)
	current_action.perform_action()
	# Reset damage
	current_action.damage = temp_damage

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 60, 0.15))
	tween.tween_callback(stats.take_damage.bind(damage))
	tween.tween_interval(0.17)

	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				queue_free()
	)

func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()


func _on_intent_ui_mouse_entered() -> void:
	intent_ui.on_mouse_entered(current_action.intent)


func _on_intent_ui_mouse_exited() -> void:
	intent_ui.on_mouse_exited()
