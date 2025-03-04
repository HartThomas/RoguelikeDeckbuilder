extends Node
@export var battleInfo : BattleInfo
@export var card_resource : CardStats
@export var player_max_health : int = 50
@export var player_health : int = 50
@export var player_block : int = 0

@export var enemy_max_health : int = 50
@export var enemy_health : int = 50
@export var enemy_block : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_cards_to_deck(['Hit', 'Hit', 'Hit', 'Hit', 'Block', 'Block', 'Block', 'Block'])


func add_cards_to_deck(array: Array[String])-> void :
	var new_battle_info = load("res://resources/battle_info.tres")
	battleInfo = new_battle_info
	for card in array:
		var resource_path = "res://resources/%s.tres" % [card.to_lower()]
		var new_card = load(resource_path)
		battleInfo.add_card_to_deck(new_card)
	battleInfo.shuffle_deck()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
