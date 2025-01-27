class_name Run
extends Node

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")

const PHYSICAL_DECK := preload("res://characters/warrior/warrior_starting_deck.tres")
const DATA_DECK := preload("res://characters/warrior/warrior_data_deck.tres")

@export var run_startup: RunStartup
@export var current_layer: CurrentLayer

@onready var map: Control = $Map
@onready var current_view: Node = $CurrentView
@onready var battle_button: Button = $"%BattleButton"
@onready var map_button: Button = $"%MapButton"


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
	Events.map_exited.connect(_on_map_exited)
	
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	map_button.pressed.connect(_show_map)

func _on_battle_room_entered() -> void:
	var battle_scene: Battle = _change_view(BATTLE_SCENE) as Battle
	match current_layer.layer:
		"Physical":
			character.deck = PHYSICAL_DECK
			battle_scene.battle_stats = preload("res://battles/physical/physical1.tres")
		"Data Link":
			character.deck = DATA_DECK
			character.max_health = 30
			battle_scene.battle_stats = preload("res://battles/data/data1.tres")
	battle_scene.char_stats = character
	battle_scene.start_battle()

func _on_map_exited(layer: String) -> void:
	current_layer.layer = layer
	_on_battle_room_entered()

func _on_battle_win() -> void:
	get_tree().paused = false
	_show_map()
	
	
