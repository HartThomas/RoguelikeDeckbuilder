extends Node
@export var battleInfo : BattleInfo
@export var card_resource : CardStats
@export var cards_to_offer : Array[Resource]

@export var player_max_health : int = 50
@export var player_health : int = 50
@export var player_block : int = 0

@export var enemy_max_health : int = 5
@export var enemy_health : int = 5
@export var enemy_block : int = 0

@export var max_physical_effort :int = 1
@export var physical_effort :int = 1

@export var max_fire_effort: int = 0
@export var fire_effort:int = 0

var card_array : Array[String] = ['Hit', 'Hit', 'Burn', 'Conserve', 'Torch', 'Augment', 'Block', 'Forget']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	form_new_deck()
	add_cards_to_deck(card_array)

func add_cards_to_deck(array: Array[String])-> void :
	for card in array:
		var resource_path = "res://resources/%s.tres" % [card.to_lower()]
		var new_card = load(resource_path).duplicate()
		new_card.set_local_to_scene(true)
		battleInfo.add_card_to_deck(new_card)
	battleInfo.shuffle_deck()

func form_new_deck() -> void:
	var new_battle_info = load("res://resources/battle_info.tres")
	battleInfo = new_battle_info

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func edit_enemy_stats(enemy: Enemy) -> void:
	enemy_max_health = enemy.max_health
	enemy_health = enemy.starting_health
	enemy_block = enemy.starting_block

func edit_cards_to_offer(cards: Array[String]) -> void :
	cards_to_offer.clear()
	if cards.size() == 0:
		cards = ['Hit', 'Conserve', 'Forget']
	for card in cards:
		var resource_path = "res://resources/%s.tres" % [card.to_lower()]
		var new_card = load(resource_path)
		new_card.set_local_to_scene(true)
		cards_to_offer.push_back(new_card)
