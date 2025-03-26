extends Control
signal card_picked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_canvas_layer_card_picked() -> void:
	$CanvasLayerUpgrade.target_position = Vector2(171,-300)


func _on_canvas_layer_finished() -> void:
	card_picked.emit()
	queue_free()
