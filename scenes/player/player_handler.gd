class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

enum Type{ATTACK, DEFEND, POWER}

@onready var defence_ui = $"../BattleUI/DefenceUI"
@onready var battle_info = $"../BattleUI/BattleInfo"

@export var hand: Hand

var character: CharacterStats
@export var played_defence = false
@export var defence_type = null

func _ready() -> void:
	Events.card_played.connect(_on_card_played)


func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.duplicate(true)
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	start_turn()


func start_turn() -> void:
	played_defence = false
	defence_type = null
	character.block = 0
	character.reset_mana()
	draw_cards(character.cards_per_turn)
	await get_tree().create_timer(1.0).timeout
	defence_ui.reset_ui()


func end_turn() -> void:
	battle_info.set_turn("Enemy")
	hand.disable_hand()
	discard_cards()
	

func draw_card() -> void:
	reshuffle_deck_from_discard()
	hand.add_card(character.draw_pile.draw_card())
	reshuffle_deck_from_discard()


func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)


func discard_cards() -> void:
	var tween := create_tween()
	for card_ui in hand.get_children():
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		func():
			Events.player_hand_discarded.emit()
	)


func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return

	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())

	character.draw_pile.shuffle()


func _on_card_played(card: Card) -> void:
	if played_defence and card.type == Type.DEFEND:
		hand.add_card(card)
		character.set_mana(character.mana+1)
		character.set_block(character.block-1)
		#print("can only play one defence card")
		Events.card_tooltip_requested.emit(null,"[center]You can only play one defence card![center]")
		await get_tree().create_timer(1.0).timeout
		Events.tooltip_hide_requested.emit()
		return
	if card.type == Type.DEFEND:
		played_defence = true
		defence_type = card.id
		defence_ui.show_defense_ui()
	character.discard.add_card(card)
