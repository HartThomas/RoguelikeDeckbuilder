extends Node2D
var merchant_stats: Merchant
signal add
signal remove
signal upgrade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_remove_button_button_down() -> void:
	remove.emit()


func _on_add_button_button_down() -> void:
	add.emit()


func _on_upgrade_button_button_down() -> void:
	upgrade.emit()
