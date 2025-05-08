extends Node2D
@export var card_scene : PackedScene
var hand : Array = []
var deck : Array = []
var depleted : Array = []
signal battle_over
var enemy : Enemy 
var conserved: bool = false
var augmented: bool = false
@onready var color_rect: ColorRect = $ColorRect
#@onready var play_area_background: Sprite2D = $PlayAreaBackground
@onready var effort_level: Sprite2D = $EffortLevel
@onready var fire_effort: Sprite2D = $FireEffort
@onready var status_bar: Node2D = $StatusBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Card.queue_free()
	var new_enemy = load("res://resources/triangle.tres")
	enemy = new_enemy
	$Enemy.play('default')
	$Player.play('default')
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
	card.mouse_hovering = false
	for clicked in clickedArray:
		clicked.is_dragging = false
	clickedArray.clear()
	if not card.in_hand and hand.has(card):
		var can_card_be_played = true
		for cost in card.card_info.card_cost:
			if BattleManager[cost] < card.card_info.card_cost[cost]:
				can_card_be_played=false
		if can_card_be_played:
			card.card_info.when_played()
			if card.card_info.attack > 0:
				edit_enemy_health(card.card_info.attack + 2 if augmented else card.card_info.attack)
			if card.card_info.block > 0:
				edit_player_block(card.card_info.block)
			depleted.append(card)
			hand.erase(card)
			arrange_depleted()
			arrange_hand_positions()
			if BattleManager.enemy.health <= 0:
				battle_over.emit()
			for cost in card.card_info.card_cost:
				use_effort(card.card_info.card_cost[cost], cost)
		else:
			card.shake_card()

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
		await get_tree().create_timer(1.2).timeout
		await _on_draw_button_down()
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
		depleted[i].z_index = i + 1

func arrange_deck_positions() -> void:
	var size = deck.size()
	for i in size:
		deck[i].in_deck = true
		deck[i].set_meta("target_position", Vector2(103,536 - (20 * i)))
		deck[i].z_index = i + 1

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
	var canvas_layer = CanvasGroup.new()
	#canvas_layer.layer = 1
	var shader = load("res://shaders/blur.gdshader")
	canvas_layer.set_material(shader)
	add_child(canvas_layer)
	var index = 0
	for card in BattleManager.battleInfo.deck:
		var new_card = card_scene.instantiate()
		var effect_dictionary = load("res://dictionaries/when_played_dictionary.gd").new()
		new_card.card_info = card
		if card.card_name == 'Forget':
			new_card.card_info.effect = forget
		if card.card_name == 'Conserve':
			new_card.card_info.effect = conserve
		if card.card_name == 'Torch':
			new_card.card_info.effect = torch
		if card.card_name == 'Burn':
			new_card.card_info.effect = burn
		if card.card_name == 'Augment':
			new_card.card_info.effect = augment
		if card.card_name == 'Pray':
			new_card.card_info.effect = pray
		if card.card_name == 'Conviction':
			new_card.card_info.effect = conviction
		if card.card_name == 'Fleam':
			new_card.card_info.effect = fleam
		if card.card_name == 'Adrenaline':
			new_card.card_info.effect = adrenaline
		if card.card_name == 'Psionics':
			new_card.card_info.effect = psionics
		if card.card_name == 'Refresh':
			new_card.card_info.effect = refresh
		new_card.position = new_card.card_info.position
		new_card.position.y -= 20 * index
		new_card.z_index = index + 1
		new_card.end_of_battle_selecting = false
		new_card.set_meta('target_position', Vector2(new_card.card_info.position.x, new_card.card_info.position.y - (20 * index)))
		new_card.clicked.connect(_on_card_clicked)
		new_card.released.connect(_on_card_released)
		new_card.mouseEntered.connect(_on_card_entered)
		new_card.forget_finished.connect(card_finished_forget)
		deck.append(new_card)
		add_child(new_card)
		index += 1
	return_effort_to_starting_values()
	BattleManager.physical_effort = BattleManager.max_physical_effort
	BattleManager.fire_effort = BattleManager.max_fire_effort
	BattleManager.holy_effort = BattleManager.max_holy_effort
	BattleManager.blood_effort = BattleManager.max_blood_effort
	BattleManager.mental_effort = BattleManager.max_mental_effort
	BattleManager.enemy.health = BattleManager.enemy.max_health
	$PlayerHealthBar.max_value = BattleManager.player.max_health
	$PlayerHealthBar.value  = BattleManager.player.health
	$PlayerHealthBar/PlayerHealthLabel.text = str(BattleManager.player.health) + '/' + str(BattleManager.player.max_health)
	$PlayerBlockBar.value = BattleManager.player.block
	if BattleManager.player.block > 0:
		$PlayerBlockBar/PlayerBlockLabel.text = str(BattleManager.player.block)
	else:
		$PlayerBlockBar/PlayerBlockLabel.text = ''
		
	$EnemyHealthBar.max_value = BattleManager.enemy.max_health
	$EnemyHealthBar.value = BattleManager.enemy.health
	$EnemyHealthBar/EnemyLabel.text = str(BattleManager.enemy.health) + '/' + str(BattleManager.enemy.max_health)
	$EnemyBlockBar.value = BattleManager.enemy.block
	if BattleManager.enemy.block > 0:
		$EnemyBlockBar/EnemyBlockLabel.text = str(BattleManager.enemy.block)
	else:
		$EnemyBlockBar/EnemyBlockLabel.text = ''
	refresh_effort_values()
	show()
	await get_tree().create_timer(0.5).timeout
	draw_hand()

func edit_player_health(amount) -> void:
	if amount >= 0:
		if BattleManager.player.block > 0:
			if BattleManager.player.block >= amount:
				BattleManager.player.block -= amount
				amount = 0
			else:
				amount -= BattleManager.player.block
				BattleManager.player.block = 0
				
			$PlayerBlockBar.value = BattleManager.player.block
			if BattleManager.player.block == 0:
				$PlayerBlockBar/PlayerBlockLabel.text = ''
			else:
				$PlayerBlockBar/PlayerBlockLabel.text = str(BattleManager.player.block)
	if BattleManager.player.health - amount > BattleManager.player.max_health:
		BattleManager.player.health = BattleManager.player.max_health
	else:
		BattleManager.player.health -= amount
	$PlayerHealthBar.value = BattleManager.player.health
	$PlayerHealthBar/PlayerHealthLabel.text = str(BattleManager.player.health) + '/' + str(BattleManager.player.max_health)

func edit_enemy_health(amount) -> void:
	if amount >= 0:
		if BattleManager.enemy.block > 0:
			if BattleManager.enemy.block >= amount:
				BattleManager.enemy.block -= amount
				amount = 0
			else:
				amount -= BattleManager.enemy.block
				BattleManager.enemy.block = 0
			$EnemyBlockBar.value = BattleManager.enemy.block
			if BattleManager.enemy.block == 0:
				$EnemyBlockBar/EnemyBlockLabel.text = ''
			else:
				$EnemyBlockBar/EnemyBlockLabel.text = str(BattleManager.enemy.block)
	if BattleManager.enemy.health - amount > BattleManager.enemy.max_health:
		BattleManager.enemy.health = BattleManager.enemy.max_health
	else:
		BattleManager.enemy.health -= amount
	$EnemyHealthBar.value = BattleManager.enemy.health
	$EnemyHealthBar/EnemyLabel.text = str(BattleManager.enemy.health) + '/' + str(BattleManager.enemy.max_health)

func edit_player_block(amount) -> void:
	BattleManager.player.block += amount
	$PlayerBlockBar.value = BattleManager.player.block
	if BattleManager.player.block ==0:
		$PlayerBlockBar/PlayerBlockLabel.text = ''
	else:
		$PlayerBlockBar/PlayerBlockLabel.text = str(BattleManager.player.block)

func edit_enemy_block(amount) -> void:
	BattleManager.enemy.block += amount
	$EnemyBlockBar.value = BattleManager.enemy.block
	$EnemyBlockBar/EnemyBlockLabel.text = str(BattleManager.enemy.block)

func end_battle()->void:
	hide()

func draw_hand() -> void:
	await get_tree().create_timer(0.5).timeout
	await _on_draw_button_down()
	await get_tree().create_timer(0.2).timeout
	await _on_draw_button_down()
	await get_tree().create_timer(0.2).timeout
	await _on_draw_button_down()

func end_turn() -> void:
	trigger_burn_damage()
	if BattleManager.enemy.health <= 0:
		battle_over.emit()
	else:
		var enemy_action = enemy.which_action_shall_i_take()
		print(enemy_action)
		if enemy_action.has('hit'):
			edit_player_health(enemy_action.get('hit'))
			var attack_sprite = Sprite2D.new()
			attack_sprite.texture = load("res://art/attack.png")
			attack_sprite.position = Vector2(0, 0)
			$Player.add_child(attack_sprite)
			var tween = get_tree().create_tween()
			tween.tween_property(attack_sprite, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
			attack_sprite.queue_free()
		if enemy_action.has('heal'):
			edit_enemy_health(-enemy_action.get('heal'))
			show_heal_effect($Enemy, enemy_action.get('heal')) 
		if enemy_action.has('block'):
			edit_enemy_block(enemy_action.get('block'))
			var block_sprite = Sprite2D.new()
			block_sprite.texture = load("res://art/block.png")
			block_sprite.position = Vector2(0, 0)
			$Enemy.add_child(block_sprite)
			var tween = get_tree().create_tween()
			tween.tween_property(block_sprite, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
			block_sprite.queue_free()
		await get_tree().create_timer(0.5).timeout
		for card in hand:
			depleted.append(card)
		hand.clear()
		arrange_depleted()
		await get_tree().create_timer(0.5).timeout
		arrange_hand_positions()
		await get_tree().create_timer(0.5).timeout
		draw_hand()
		reset_effort()

func use_effort(amount, type_of_effort) -> void:
	BattleManager[type_of_effort] -= amount
	refresh_effort_values()

func reset_effort() -> void:
	if BattleManager.max_physical_effort > 0 :
		
		if conserved:
			BattleManager.physical_effort = BattleManager.max_physical_effort + 1
		else:
			BattleManager.physical_effort = BattleManager.max_physical_effort
		animate_effort_reset($EffortLevel)
	if BattleManager.max_fire_effort > 0:
		BattleManager.fire_effort = BattleManager.max_fire_effort
		animate_effort_reset($FireEffort)
	if BattleManager.max_holy_effort > 0:
		BattleManager.holy_effort = BattleManager.max_holy_effort
		animate_effort_reset($HolyEffort)
	if BattleManager.max_blood_effort > 0:
		BattleManager.blood_effort = BattleManager.max_blood_effort
		animate_effort_reset($BloodEffort)
	refresh_effort_values()
	conserved = false

func animate_effort_reset(sprite) -> void:
	var shader = sprite.get_material()
	shader.set_shader_parameter('softness', 0.1)
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_radius.bind(shader),0.0, 0.5, 0.25)
	tween.tween_method(set_shader_fade.bind(shader), 0.0, 1.0, 0.5)

func set_shader_radius(value, shader) -> void:
	shader.set_shader_parameter('radius', value)

func set_shader_fade( value,shader) -> void:
	shader.set_shader_parameter('fade', value)
 

func forget() -> void:
	var card = hand.filter(func(c) : return c.card_info.card_name != 'Forget').pick_random()
	if card:
		card.forget_card()

func card_finished_forget(card)-> void:
	hand.erase(card)
	card.queue_free()
	arrange_hand_positions()

func conserve() -> void:
	conserved = true

func augment() ->  void:
	augmented = true

func torch() -> void:
	BattleManager.max_fire_effort += 1
	$FireEffortLabel.text = str(BattleManager.fire_effort) + '/' + str(BattleManager.max_fire_effort)

func burn() ->  void:
	burn_enemy(3)
	if not BattleManager.enemy.status_list.has('flame'):
		BattleManager.enemy.status_list.append('flame')
		status_bar.refresh_status_bar()

func burn_enemy (amount) -> void:
	enemy.burn_amount += amount

func trigger_burn_damage() -> void:
	if enemy.burn_amount > 0:
		edit_enemy_health(enemy.burn_amount)
		enemy.burn_amount -= 1
	if enemy.burn_amount < 1:
		BattleManager.enemy.status_list.erase('flame')
		status_bar.refresh_status_bar()

func refresh_effort_values() -> void:
	$EffortLabel.text = str(BattleManager.physical_effort) + '/' + str(BattleManager.max_physical_effort)
	$FireEffortLabel.text = str(BattleManager.fire_effort) + '/' + str(BattleManager.max_fire_effort)
	$HolyEffortLabel.text = str(BattleManager.holy_effort) + '/' + str(BattleManager.max_holy_effort)
	$BloodEffortLabel.text = str(BattleManager.blood_effort) + '/' + str(BattleManager.max_blood_effort)
	$MentalEffortLabel.text = str(BattleManager.mental_effort) + '/' + str(BattleManager.max_mental_effort)

func return_effort_to_starting_values() -> void:
	for effort in BattleManager.starting_effort_values:
		BattleManager[effort] = BattleManager.starting_effort_values[effort]

func _on_play_area_entered(area: Area2D) -> void:
	if area.get('in_hand'):
		#play_area_background.start_shader()
		pass

func _on_play_area_exited(area: Area2D) -> void:
	#play_area_background.stop_shader()
	pass

func pray() -> void:
	BattleManager.max_holy_effort += 1
	$HolyEffortLabel.text = str(BattleManager.holy_effort) + '/' + str(BattleManager.max_holy_effort)

func conviction() -> void:
	BattleManager.max_mental_effort += 1
	$MentalEffortLabel.text = str(BattleManager.mental_effort) + '/' + str(BattleManager.max_mental_effort)

func fleam() ->  void:
	BattleManager.max_blood_effort += 1
	$BloodEffortLabel.text = str(BattleManager.blood_effort) + '/' + str(BattleManager.max_blood_effort)

func adrenaline() ->  void:
	BattleManager.physical_effort += 1
	$EffortLabel.text = str(BattleManager.physical_effort) + '/' + str(BattleManager.max_physical_effort)

func psionics() -> void:
	if BattleManager.enemy.health < 5:
		battle_over.emit()

func refresh() -> void:
	BattleManager.physical_effort += 1
	$EffortLabel.text = str(BattleManager.physical_effort) + '/' + str(BattleManager.max_physical_effort)
	_on_draw_button_down()

func show_heal_effect(target_node: Node2D, amount := 5):
	for i in amount:
		create_heal_cross(target_node)
		await get_tree().create_timer(0.1).timeout

func create_heal_cross(target_node: Node2D) -> void:
	var cross := Node2D.new()
	var size := 4.0
	var thickness := 2.0
	var color := Color(0, 1, 0, 1)
	
	var vert := ColorRect.new()
	vert.color = color
	vert.size = Vector2(thickness, size * 2)
	vert.position = Vector2(-thickness / 2, -size)
	cross.add_child(vert)
	
	var hori := ColorRect.new()
	hori.color = color
	hori.size = Vector2(size * 2, thickness)
	hori.position = Vector2(-size, -thickness / 2)
	cross.add_child(hori)
	
	var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	cross.position = offset
	target_node.add_child(cross)
	var tween = get_tree().create_tween()
	var final_pos = offset + Vector2(0, -30)
	tween.tween_property(cross, "position", final_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(vert, "modulate:a", 0.0, 0.5)
	tween.tween_property(hori, "modulate:a", 0.0, 0.5)
	await tween.finished
	cross.queue_free()
