extends ScrollContainer

@export var card_scene : PackedScene
@onready var flow_container: FlowContainer = $FlowContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_types = ['Physical', 'Mental', 'Fire', 'Holy', 'Blood']
	for type in card_types:
		var group_container = VBoxContainer.new()
		group_container.custom_minimum_size = Vector2(400, 0)
		var label = Label.new()
		label.text = type
		label.custom_minimum_size = Vector2(50, 100)
		label.add_theme_font_size_override('font_size', 30)
		group_container.add_child(label)
		var binder_container = GridContainer.new()
		binder_container.columns = 4
		group_container.add_child(binder_container)
		flow_container.add_child(group_container)
		var cards_of_type = get_cards_by_type(type.to_lower())
		for card in cards_of_type:
			var card_in_binder = card_scene.instantiate()
			card_in_binder.card_info = card
			var control = Control.new()
			control.custom_minimum_size = Vector2(100, 170)
			control.mouse_filter = Control.MOUSE_FILTER_PASS
			control.add_child(card_in_binder)
			card_in_binder.in_binder = true
			binder_container.add_child(control)
			await get_tree().process_frame
		var rows = ceil(cards_of_type.size() / 4.0)
		binder_container.custom_minimum_size = Vector2(400, rows * 170)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_cards_by_type( type_name: String) -> Array:
	var matching_cards: Array = []
	for card_name in BattleManager.all_cards:
		var path = "res://resources/%s.tres" % card_name.to_lower()
		var card = load(path)
		if card == null:
			print("Warning: Failed to load card resource at", path)
			continue
		var card_type = ""
		if card.card_cost.fire_effort > 0:
			card_type = "fire"
		elif card.card_cost.blood_effort > 0:
			card_type = "blood"
		elif card.card_cost.holy_effort > 0:
			card_type = "holy"
		elif card.card_cost.mental_effort > 0:
			card_type = "mental"
		elif card.card_cost.physical_effort > 0:
			card_type = "physical"
		if card_type == type_name:
			matching_cards.append(card)
	return matching_cards
