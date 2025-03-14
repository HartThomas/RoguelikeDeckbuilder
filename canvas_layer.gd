extends CanvasLayer
@onready var panel: Panel = $Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_scene = load("res://card.tscn")
	var hit = load("res://resources/hit.tres")
	var conserve = load("res://resources/conserve.tres")
	var forget = load("res://resources/forget.tres")
	var array = [hit, conserve, forget]
	var index = 0
	for i in array:
		var new_card = card_scene.instantiate()
		new_card.card_info = i
		new_card.position.x = 150 + (250 * index)
		new_card.position.y = 400 
		new_card.scale = Vector2(2, 2)
		panel.add_child(new_card)
		new_card.card_flip()
		index += 1
	panel.position = Vector2(171,-300)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	panel.position = panel.position.lerp(Vector2(171,-24), 5 * delta)
	
