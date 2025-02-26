extends Node
@export var battleInfo : BattleInfo
@export var card_resource : CardStats
@export var player_max_health : int = 50
@export var enemy_max_health : int = 5
@export var player_health : int = 50
@export var enemy_health : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_battle_info = load("res://resources/battle_info.tres")
	battleInfo = new_battle_info
	var new_card = load("res://resources/hit.tres")
	battleInfo.add_card_to_deck(new_card)
	battleInfo.add_card_to_deck(new_card)
	battleInfo.add_card_to_deck(new_card)
	if card_resource:
		card_resource.card_name = 'Hit'
		print(card_resource)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
