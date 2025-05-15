extends ScrollContainer

@export var card_scene : PackedScene
@onready var binder_container: GridContainer = $BinderContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card in BattleManager.all_cards:
		var control = Control.new()
		var card_in_binder = card_scene.instantiate()
		var card_stats = load("res://resources/%s.tres" % [card.to_lower()])
		card_in_binder.card_info = card_stats
		control.add_child(card_in_binder)
		await get_tree().process_frame
		card_in_binder.in_binder = true
		binder_container.add_child(control)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
