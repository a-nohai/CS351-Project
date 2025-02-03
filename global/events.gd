extends Node

# Card-related events
signal card_drag_started (card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started (card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_tooltip_requested(card: Card)
signal tooltip_hide_requested

# Player-related events
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_ended
signal player_hit
signal player_died

# Enemy-related events
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended

#Battle-related events
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
signal mcq_screen_requested(question_text: String, correct_index: int, options: Array)
signal mcq_answered(correct: bool)
signal battle_won
signal battle_lost

#Map-related events
signal map_exited

#Battle Reward-related events
signal battle_reward_exited
