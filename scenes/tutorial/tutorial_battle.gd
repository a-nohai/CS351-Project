class_name TutorialBattle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var current_layer: CurrentLayer

@onready var battle_ui: BattleUI = $BattleUI 
@onready var player_handler: PlayerHandler = $PlayerHandler 
@onready var enemy_handler: EnemyHandler = $EnemyHandler 
@onready var player: Player = $Player 
@onready var mcq_panel: MCQPanel = $MCQHandler/MCQLayer/MCQPanel
@onready var battle_info: BattleInfo = $BattleUI/BattleInfo


func _ready() -> void:

	Events.mcq_answered.connect(_on_mcq_answered)
	
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	$TutorialHighlights/Arrow.visible = false


func _on_mcq_answered(correct: bool) -> void:
	if correct:
		print("Correct answer!")

	else:
		print("Incorrect answer!")

func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	battle_info.set_turn("Player")
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions()
	player_handler.start_battle(char_stats)

func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		Events.battle_over_screen_requested.emit("Victory!", BattleOverPanel.Type.WIN)

func _on_enemy_turn_ended() -> void:
	battle_info.set_turn("Player")
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()

func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
