class_name Run
extends Node

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")

const PHYSICAL_DECK := preload("res://characters/warrior/warrior_physical_deck.tres")
const DATA_DECK := preload("res://characters/warrior/warrior_data_deck.tres")
const APPLICATION_DECK := preload("res://characters/warrior/warrior_application_deck.tres")
const NETWORK_DECK := preload("res://characters/warrior/warrior_network_deck.tres")
const PRESENTATION_DECK := preload("res://characters/warrior/warrior_presentation_deck.tres")
const SESSION_DECK := preload("res://characters/warrior/warrior_session_deck.tres")
const TRANSPORT_DECK := preload("res://characters/warrior/warrior_transport_deck.tres")

@export var run_startup: RunStartup
@export var current_layer: CurrentLayer

@onready var map: Control = $Map
@onready var current_view: Node = $CurrentView
@onready var battle_button: Button = $"%BattleButton"
@onready var map_button: Button = $"%MapButton"

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
	Events.map_exited.connect(_on_map_exited)
	
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	map_button.pressed.connect(_show_map)

func _on_battle_room_entered() -> void:
	var battle_scene: Battle = await _change_view(BATTLE_SCENE) as Battle
	match current_layer.layer:
		"Physical":
			character.deck = PHYSICAL_DECK
			battle_scene.battle_stats = preload("res://battles/physical/physical1.tres")
		"Data Link":
			character.deck = DATA_DECK
			battle_scene.battle_stats = preload("res://battles/data/data1.tres")
		"Application":
			character.deck = APPLICATION_DECK
			battle_scene.battle_stats = preload("res://battles/application/application1.tres")
		"Network":
			character.deck = NETWORK_DECK
			battle_scene.battle_stats = preload("res://battles/network/network1.tres")
		"Presentation":
			character.deck = PRESENTATION_DECK
			battle_scene.battle_stats = preload("res://battles/presentation/presentation1.tres")
		"Session":
			character.deck = SESSION_DECK
			battle_scene.battle_stats = preload("res://battles/session/session1.tres")
		"Transport":
			character.deck = TRANSPORT_DECK
			battle_scene.battle_stats = preload("res://battles/transport/transport1.tres")
	battle_scene.char_stats = character
	prev_battle = battle_scene.battle_stats
	battle_scene.start_battle()

func _on_map_exited(layer: String) -> void:
	current_layer.layer = layer
	_on_battle_room_entered()

func _on_battle_win() -> void:
	get_tree().paused = false
	if not prev_battle.final_battle:
		var battle_path = prev_battle.get_path()
		var regex = RegEx.new()
		regex.compile("\\d+")
		var numbers_found = regex.search(battle_path)
		var number_found = int(numbers_found.get_string())
		var new_battle_num = number_found+1
		
		var new_path = battle_path.replace(str(number_found), str(new_battle_num))
		var new_battle_scene: Battle = await _change_view(BATTLE_SCENE) as Battle
		match current_layer.layer:
			"Physical":
				character.deck = PHYSICAL_DECK
			"Data Link":
				character.deck = DATA_DECK
			"Application":
				character.deck = APPLICATION_DECK
			"Network":
				character.deck = NETWORK_DECK
			"Presentation":
				character.deck = PRESENTATION_DECK
			"Session":
				character.deck = SESSION_DECK
			"Transport":
				character.deck = TRANSPORT_DECK
		new_battle_scene.battle_stats = load(new_path)
		new_battle_scene.char_stats = character
		prev_battle = new_battle_scene.battle_stats
		new_battle_scene.start_battle()
	else:
		_show_map()
	
func _on_battle_lost() -> void:
	get_tree().paused = false
	print("battle lost")
	_show_map()
