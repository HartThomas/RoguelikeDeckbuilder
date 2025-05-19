extends Control
@export var card_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_card = card_scene.instantiate()
	new_card.in_card_zoom = true
	new_card.position = Vector2(300,250)
	add_child(new_card)
	new_card.card_flip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
