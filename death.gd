extends Control
@onready var panel: Panel = $Panel
@onready var animation_tree: AnimationPlayer = $Panel/Button/AnimationTree
@onready var button: Button = $Panel/Button

signal menu_button_clicked
signal finished
var finishing :bool = false
var target_position = Vector2(171,-24)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finishing = true
	panel.position = Vector2(171,-300)
	button.modulate.a = 0

func _process(delta: float) -> void:
	panel.position = panel.position.lerp(target_position, 5 * delta)
	if panel.position.distance_to(target_position) < 1.0 and finishing:
		finishing = false
		animation_tree.play('fade_in')

func _on_button_button_down() -> void:
	menu_button_clicked.emit()
