extends Control
@export var card_scene : PackedScene
@onready var background: TextureRect = $Background
var card_stats : CardStats
@onready var box_container: BoxContainer = $ScrollContainer/BoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_card = card_scene.instantiate()
	new_card.in_card_zoom = true
	if card_stats:
		new_card.card_info = card_stats
	new_card.position = Vector2(150,250)
	new_card.scale = Vector2(1.5, 1.5)
	background.add_child(new_card)
	new_card.card_flip()
	if card_stats and card_stats.card_text.contains('Burn'):
		var new_label = Label.new()
		new_label.text = "Burn: Deals damage at the end of each turn then reduces by 1."
		box_container.add_child(new_label)
	if card_stats and card_stats.card_text.contains('Stun'):
		var new_label = Label.new()
		new_label.text = "Stun: Enemy skips their turns while stunned"
		box_container.add_child(new_label)
	if card_stats and card_stats.card_text.contains('action'):
		var new_label = Label.new()
		new_label.text = "Action: enemy uses an action at the end of your turn"
		box_container.add_child(new_label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		queue_free()
