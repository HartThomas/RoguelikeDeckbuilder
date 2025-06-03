extends CanvasLayer
@onready var panel: Panel = $Panel
signal card_picked
signal finished
var finishing :bool = false
var target_position = Vector2(171,-24)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BattleManager.edit_cards_to_offer(BattleManager.random_cards(3, BattleManager.all_cards))
	#print(BattleManager.cards_to_offer)
	var card_scene = load("res://card.tscn")
	var index = 0
	for i in BattleManager.cards_to_offer:
		var new_card = card_scene.instantiate()
		new_card.card_info = i
		new_card.position.x = 150 + (250 * index)
		new_card.position.y = 400 
		new_card.scale = Vector2(2, 2)
		new_card.add_to_deck.connect(add_card_to_deck)
		new_card.end_of_battle_selecting = true
		panel.add_child(new_card)
		new_card.card_flip()
		index += 1
	panel.position = Vector2(171,-300)

func _process(delta: float) -> void:
	panel.position = panel.position.lerp(target_position, 5 * delta)
	if panel.position.distance_to(target_position) < 1.0 and finishing:
		finished.emit()

func add_card_to_deck(card) -> void:
	finishing = true
	BattleManager.add_cards_to_deck([card.card_info.card_name])
	card_picked.emit()
