extends Node2D
@export var card_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Card.queue_free()

	var index = 0
	for card in BattleManager.battleInfo.cards_in_deck:
		var new_card = card_scene.instantiate()
		new_card.card_info = card
		new_card.position = new_card.card_info.position
		new_card.position.y -= 20 * index
		new_card.set_meta('target_position', Vector2(new_card.card_info.position.x, new_card.card_info.position.y - (20 * index)))
		add_child(new_card)
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
