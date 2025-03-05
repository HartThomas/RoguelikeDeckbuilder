extends Node2D
@export var card_scene : PackedScene
var hand : Array = []
var deck : Array = []
var depleted : Array = []
signal battle_over
var enemy : Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Card.queue_free()
	var new_enemy = load("res://resources/triangle.tres")
	enemy = new_enemy
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
		print({'attack':card.card_info.attack, 'block':card.card_info.block})
		edit_enemy_health(card.card_info.attack)
		edit_player_block(card.card_info.block)
		depleted.append(card)
		hand.erase(card)
		arrange_depleted()
		arrange_hand_positions()
		if BattleManager.enemy_health <= 0:
			battle_over.emit()
	var enemy_action = enemy.which_action_shall_i_take()
	print(enemy_action)
	if enemy_action.has('hit'):
		edit_player_health(enemy_action.get('hit'))
	if enemy_action.has('heal'):
		edit_enemy_health(-enemy_action.get('heal'))
	if enemy_action.has('block'):
		edit_enemy_block(enemy_action.get('block'))

func _on_draw_button_down() -> void:
	if deck.size() == 0:
		if depleted.size() == 0:
			return

		for i in depleted.size():
			var card = depleted[i]
			deck.append(card)
			card.trigger_card_flip_to_deck_animation()
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
	$Player/BlockBar.value = BattleManager.player_block
	if BattleManager.player_block > 0:
		$Player/BlockBar/BlockLabel.text = BattleManager.player_block
	else:
		$Player/BlockBar/BlockLabel.text = ''
		
	$Enemy/HealthBar.max_value = BattleManager.enemy_max_health
	$Enemy/HealthBar.value = BattleManager.enemy_health
	$Enemy/HealthBar/Label.text = str(BattleManager.enemy_health) + '/' + str(BattleManager.enemy_max_health)
	$Enemy/BlockBar.value = BattleManager.enemy_block
	if BattleManager.enemy_block > 0:
		$Enemy/BlockBar/BlockLabel.text = BattleManager.enemy_block
	else:
		$Enemy/BlockBar/BlockLabel.text = ''
	show()
	await get_tree().create_timer(0.5).timeout
	draw_hand()


func edit_player_health(amount) -> void:
	if BattleManager.player_block > 0:
		if BattleManager.player_block >= amount:
			BattleManager.player_block -= amount
			amount = 0
		else:
			amount -= BattleManager.player_block
			BattleManager.player_block = 0
			
		$Player/BlockBar.value = BattleManager.player_block
		if BattleManager.player_block == 0:
			$Player/BlockBar/BlockLabel.text = ''
		else:
			$Player/BlockBar/BlockLabel.text = str(BattleManager.player_block)
	if BattleManager.player_health - amount > BattleManager.player_max_health:
		BattleManager.player_health = BattleManager.player_max_health
	else:
		BattleManager.player_health -= amount
	$Player/HealthBar.value = BattleManager.player_health
	$Player/HealthBar/HealthLabel.text = str(BattleManager.player_health) + '/' + str(BattleManager.player_max_health)

func edit_enemy_health(amount) -> void:
	if BattleManager.enemy_block > 0:
		if BattleManager.enemy_block >= amount:
			BattleManager.enemy_block -= amount
			amount = 0
		else:
			amount -= BattleManager.enemy_block
			BattleManager.enemy_block = 0
		$Enemy/BlockBar.value = BattleManager.enemy_block
		if BattleManager.enemy_block == 0:
			$Enemy/BlockBar/BlockLabel.text = ''
		else:
			$Enemy/BlockBar/BlockLabel.text = str(BattleManager.enemy_block)
	if BattleManager.enemy_health - amount > BattleManager.enemy_max_health:
		BattleManager.enemy_health = BattleManager.enemy_max_health
	else:
		BattleManager.enemy_health -= amount
	$Enemy/HealthBar.value = BattleManager.enemy_health
	$Enemy/HealthBar/Label.text = str(BattleManager.enemy_health) + '/' + str(BattleManager.enemy_max_health)

func edit_player_block(amount) -> void:
	BattleManager.player_block += amount
	$Player/BlockBar.value = BattleManager.player_block
	$Player/BlockBar/BlockLabel.text = str(BattleManager.player_block)

func edit_enemy_block(amount) -> void:
	BattleManager.enemy_block += amount
	$Enemy/BlockBar.value = BattleManager.enemy_block
	$Enemy/BlockBar/BlockLabel.text = str(BattleManager.enemy_block)

func end_battle()->void:
	hide()

func draw_hand() -> void:
	_on_draw_button_down()
	await get_tree().create_timer(0.2).timeout
	_on_draw_button_down()
	await get_tree().create_timer(0.2).timeout
	_on_draw_button_down()
