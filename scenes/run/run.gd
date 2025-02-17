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
const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"

@export var run_startup: RunStartup
@export var current_layer: CurrentLayer
@export var points: int = 0
@export var wrong_answers: QuestionData

@onready var map: Control = $Map
@onready var current_view: Node = $CurrentView
@onready var battle_button: Button = $"%BattleButton"
@onready var map_button: Button = $"%MapButton"
@onready var points_ui: PointsUI = $PointsUI
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var wrong_answers_panel: WrongAnswersPanel = $WrongAnswersPanel

var prev_battle: BattleStats

var character: CharacterStats

var save_data: SaveGame


func _ready() -> void:
	if not run_startup:
		return
	
	pause_menu.save_and_quit.connect(_save_and_quit)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			var warrior := load("res://characters/warrior/warrior.tres")
			character = warrior.create_instance()
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			_load_run()

func _start_run() -> void:
	_setup_event_connections()
	
	save_data = SaveGame.new()
	_save_run(true)

func _save_and_quit() -> void:
	_save_run(true)
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _save_run(was_on_map: bool) -> void:
	save_data.current_layer = current_layer.max_points
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.was_on_map = was_on_map
	print("save")
	print(points)
	print(current_layer.max_points)
	save_data.points = points
	save_data.save_data()

func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save")
	
	current_layer.max_points = save_data.current_layer
	character = save_data.char_stats
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	points = save_data.points
	print("load")
	print(points)
	print(current_layer.max_points)
	_setup_event_connections()
	
	Events.points_changed.emit(points)
	
	for layer in current_layer.max_points:
		if current_layer.max_points[layer] != 0:
			map.set_layer_points(layer, current_layer.max_points[layer])
	

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
	Events.points_changed.connect(_on_points_changed)
	Events.briefing_read.connect(_on_briefing_read)
	
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
		"Final":
			character.deck = TRANSPORT_DECK
			battle_scene.battle_stats = preload("res://battles/final/final.tres")
	character.set_health(character.max_health)
	battle_scene.battle_info.set_layer(current_layer.layer)
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
		new_battle_scene.battle_info.set_layer(current_layer.layer)
		prev_battle = new_battle_scene.battle_stats
		new_battle_scene.start_battle()
	else:
		var points_won = 0
		if character.health >= 30:
			points_won = 3
		elif character.health >= 18 and character.health < 30:
			points_won = 2
		else:
			points_won = 1
		if points_won > current_layer.max_points[current_layer.layer]:
			points = points - current_layer.max_points[current_layer.layer] + points_won
			current_layer.set_max_points(points_won, current_layer.layer)
			print(current_layer.layer)
			map.set_layer_points(current_layer.layer, points_won)
		Events.points_changed.emit(points)
		character.set_health(character.max_health)
		_show_map()
	
func _on_battle_lost() -> void:
	get_tree().paused = false
	print("battle lost")
	wrong_answers_panel.visible = true
	wrong_answers_panel.populate_scrollable(wrong_answers.questions)
	character.set_health(character.max_health)
	_show_map()

func _on_briefing_read() -> void:
	wrong_answers_panel.visible = false
	wrong_answers_panel.depopulate_scrollable()
	wrong_answers.questions = {}

func _on_points_changed(added_points: int) -> void:
	points_ui.set_points(added_points)
	match added_points:
		4,5,6:
			map.enable_button(3)
		7,8,9:
			map.enable_button(3)
			map.enable_button(4)
		10,11,12:
			map.enable_button(3)
			map.enable_button(4)
			map.enable_button(5)
		13,14,15,16,17:
			map.enable_button(3)
			map.enable_button(4)
			map.enable_button(5)
			map.enable_button(6)
		18,19,20:
			map.enable_button(3)
			map.enable_button(4)
			map.enable_button(5)
			map.enable_button(6)
			map.enable_button(7)
		21:
			map.enable_button(3)
			map.enable_button(4)
			map.enable_button(5)
			map.enable_button(6)
			map.enable_button(7)
			map.enable_button(8)
		
	for layer in current_layer.max_points:
		if current_layer.max_points[layer] != 0:
			map.set_layer_points(layer, current_layer.max_points[layer])
