class_name Tutorial
extends Node

const TUTORIAL_SCENE := preload("res://scenes/tutorial/tutorial_battle.tscn")
const RUN_SCENE := preload("res://scenes/run/run.tscn")

const TUTORIAL_DECK := preload("res://characters/warrior/warrior_tutorial_deck.tres")


@export var run_startup: RunStartup
@export var current_layer: CurrentLayer
@export var points: int = 0

@onready var map: Control = $TutorialMap
@onready var current_view: Node = $CurrentView
@onready var battle_button: Button = $"%BattleButton"
@onready var map_button: Button = $"%MapButton"
@onready var points_ui: PointsUI = $PointsUI

var prev_battle: BattleStats

var character: CharacterStats

func _ready() -> void:
	if not run_startup:
		return
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			var warrior := load("res://characters/warrior/warrior.tres")
			character = warrior.create_instance()
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			print("TODO: load previous run")

func _start_run() -> void:
	_setup_event_connections()
	
func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		await current_view.get_child(0).tree_exited
		
	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	map.hide_map()
	return new_view

func _show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	map.show_map()

func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_win)
	Events.battle_lost.connect(_on_battle_lost)
	Events.tutorial_map_exited.connect(_on_map_exited)
	
	battle_button.pressed.connect(_change_view.bind(TUTORIAL_SCENE))
	map_button.pressed.connect(_show_map)

func _on_battle_room_entered() -> void:
	var battle_scene: TutorialBattle = await _change_view(TUTORIAL_SCENE) as TutorialBattle
	character.deck = TUTORIAL_DECK
	battle_scene.battle_stats = preload("res://battles/tutorial/tutorial.tres")
	battle_scene.battle_info.set_layer(current_layer.layer)
	battle_scene.char_stats = character
	prev_battle = battle_scene.battle_stats
	battle_scene.start_battle()

func _on_map_exited() -> void:
	_on_battle_room_entered()

func _on_battle_win() -> void:
	get_tree().paused = false
	print("won tut")
	get_tree().change_scene_to_packed(RUN_SCENE)
	#_show_map()
	
func _on_battle_lost() -> void:
	get_tree().paused = false
	print("battle lost")
	character.set_health(character.max_health)
	_show_map()
