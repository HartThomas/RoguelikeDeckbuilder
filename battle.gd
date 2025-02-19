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
		new_card.z_index = index
		new_card.set_meta('target_position', Vector2(new_card.card_info.position.x, new_card.card_info.position.y - (20 * index)))
		new_card.clicked.connect(_on_card_clicked)
		new_card.released.connect(_on_card_released)
		new_card.add_to_group('deck')
		add_child(new_card)
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var clickedArray: Array = []

func _on_card_clicked(card) -> void:
	clickedArray.append(card)
	clickedArray.sort_custom(func(a,b): return a.z_index > b.z_index)
	var i = 0
	for clicked in clickedArray:
		if i == 0:
			clicked.is_dragging = true
		else:
			clicked.is_dragging = false
		i += 1

func _on_card_released() -> void:
	for clicked in clickedArray:
		clicked.is_dragging = false
	clickedArray.clear()

func _on_draw_button_down() -> void:
	var nodesInDeckGroup = get_tree().get_nodes_in_group('deck')
	if nodesInDeckGroup.size() == 0:
		return
	nodesInDeckGroup[nodesInDeckGroup.size() - 1].remove_from_group('deck')
	nodesInDeckGroup[nodesInDeckGroup.size() - 1].add_to_group('hand')
	arrange_hand_positions()

var hand_width : float = 0.0
var hand_position : Vector2

func arrange_hand_positions() -> void:
	var hand_shape = $Hand/HandCollisionShape2D
	if hand_shape and hand_shape.shape is RectangleShape2D:
		hand_width = hand_shape.shape.size.x
		hand_position = hand_shape.position
	var nodesInHandGroup = get_tree().get_nodes_in_group('hand')
	var number_cards_in_hand = nodesInHandGroup.size()
	if number_cards_in_hand == 0 or hand_width == 0:
		return
	var start_x = hand_position.x - hand_width / 2  
	var spacing = hand_width / (number_cards_in_hand + 1) 

	for i in range(number_cards_in_hand):
		var card = nodesInHandGroup[i]
		card.set_meta("target_position", Vector2(start_x + (i + 1) * spacing, hand_position.y ))
