extends CanvasLayer
@onready var panel: Panel = $Panel
var target_position = Vector2(171,-24)
signal finished
signal card_picked
var finishing :bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.position = Vector2(171,-300)
	var card_scene = load("res://card.tscn")
	
	var total_cards = BattleManager.battleInfo.deck.size()
	if total_cards == 0:
		return
	
	var start_position = Vector2(58, 200)
	var space_width = 824
	var card_width = 100 
	var card_height = 140
	var max_per_row = int(max(1, space_width / (card_width * 1.2)))
	var rows = ceil(float(total_cards) / max_per_row)
	var spacing_x = min(space_width / max(1, min(total_cards, max_per_row)), card_width * 1.2)
	var spacing_y = card_height * 1.2
	
	for i in range(total_cards):
		var card_instance = card_scene.instantiate()
		card_instance.card_info = BattleManager.battleInfo.deck[i]
		var row = i / max_per_row
		var col = i % int(max_per_row)
		var position_x = start_position.x + (space_width - (spacing_x * min(total_cards, max_per_row))) / 2 + col * spacing_x
		var position_y = start_position.y + row * spacing_y
		card_instance.position = Vector2(position_x, position_y)
		card_instance.scale = Vector2(1.5,1.5)
		card_instance.add_to_deck.connect(remove_card_from_deck)
		card_instance.end_of_battle_selecting = true
		panel.add_child(card_instance)
		card_instance.card_flip()

func _process(delta: float) -> void:
	panel.position = panel.position.lerp(target_position, 5 * delta)
	if panel.position.distance_to(target_position) < 1.0 and finishing:
		finished.emit()

func remove_card_from_deck(card) -> void:
	finishing = true
	BattleManager.battleInfo.remove_card_from_deck(card.card_info)
	card_picked.emit()
