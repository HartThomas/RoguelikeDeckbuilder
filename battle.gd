extends Node2D
@export var card_scene : PackedScene
var hand : Array = []
var deck : Array = []
var depleted : Array = []
signal battle_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Card.queue_free()
	hide()

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

func _on_card_released(card) -> void:
	for clicked in clickedArray:
		clicked.is_dragging = false
	clickedArray.clear()
	if not card.in_hand and hand.has(card):
		edit_enemy_health(card.card_info.attack)
		
		depleted.append(card)
		hand.erase(card)
		arrange_depleted()
		arrange_hand_positions()
		if BattleManager.enemy_health <= 0:
			battle_over.emit()

func _on_draw_button_down() -> void:
	if deck.size() == 0:
		if depleted.size() == 0:
			return

		for i in depleted.size():
			var card = depleted[i]
			deck.append(card)
			card.trigger_card_flip_animation()
		depleted.clear()
		deck.shuffle()
		arrange_deck_positions()
	else:
		hand.append(deck[deck.size() - 1])
		deck.remove_at(deck.size() - 1)
		hand[hand.size() - 1].trigger_card_flip_animation()
		arrange_hand_positions()

var hand_width : float = 0.0
var hand_position : Vector2

func arrange_hand_positions() -> void:
	var hand_shape = $Hand/HandCollisionShape2D
	if hand_shape and hand_shape.shape is RectangleShape2D:
		hand_width = hand_shape.shape.size.x
		hand_position = hand_shape.position
	var number_hand = hand.size()
	if number_hand == 0 or hand_width == 0:
		return
	var start_x = hand_position.x - hand_width / 2  
	var spacing = hand_width / (number_hand + 1) 
	for i in range(number_hand):
		var card = hand[i]
		card.in_deck = false
		card.set_meta("target_position", Vector2(start_x + (i + 1) * spacing, hand_position.y ))

func _on_hand_area_exited(area: Area2D) -> void:
	area.in_hand = false

func _on_hand_area_entered(area: Area2D) -> void:
	area.in_hand = true

func arrange_depleted() -> void:
	var size = depleted.size()
	for i in size:
		depleted[i].in_deck = false
		depleted[i].set_meta("target_position", Vector2(1048,538 - (20 * i)))
		depleted[i].z_index = i

func arrange_deck_positions() -> void:
	var size = deck.size()
	for i in size:
		deck[i].in_deck = true
		deck[i].set_meta("target_position", Vector2(103,536 - (20 * i)))
		deck[i].z_index = i

var temporary_card: PackedScene

func _on_card_entered(card, entered) -> void:
	if not hand.has(card):
		return

func start_battle()->void:
	deck.clear()
	hand.clear()
	depleted.clear()
	
	var cards = get_children().filter(func(card) : return 'card_info' in card)
	for card in cards:
		card.queue_free()
	
	var index = 0
	for card in BattleManager.battleInfo.deck:
		var new_card = card_scene.instantiate()
		new_card.card_info = card
		new_card.position = new_card.card_info.position
		new_card.position.y -= 20 * index
		new_card.z_index = index
		new_card.set_meta('target_position', Vector2(new_card.card_info.position.x, new_card.card_info.position.y - (20 * index)))
		new_card.clicked.connect(_on_card_clicked)
		new_card.released.connect(_on_card_released)
		new_card.mouseEntered.connect(_on_card_entered)
		deck.append(new_card)
		add_child(new_card)
		index += 1
	BattleManager.enemy_health = BattleManager.enemy_max_health
	$Player/HealthBar.max_value = BattleManager.player_max_health
	$Player/HealthBar.value  = BattleManager.player_health
	$Player/HealthBar/HealthLabel.text = str(BattleManager.player_health) + '/' + str(BattleManager.player_max_health)
	$Enemy/HealthBar.max_value = BattleManager.enemy_max_health
	$Enemy/HealthBar.value = BattleManager.enemy_health
	$Enemy/HealthBar/Label.text = str(BattleManager.enemy_health) + '/' + str(BattleManager.enemy_max_health)
	show()

func edit_player_health(amount) -> void:
	BattleManager.player_health -= amount
	$Player/HealthBar.value = BattleManager.player_health
	$Player/HealthBar/HealthLabel.text = str(BattleManager.player_health) + '/' + str(BattleManager.player_max_health)

func edit_enemy_health(amount) -> void:
	BattleManager.enemy_health -= amount
	$Enemy/HealthBar.value = BattleManager.enemy_health
	$Enemy/HealthBar/Label.text = str(BattleManager.enemy_health) + '/' + str(BattleManager.enemy_max_health)

func end_battle()->void:
	hide()
