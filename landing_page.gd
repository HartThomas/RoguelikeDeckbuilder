extends Control

@export var starter_scene : PackedScene
@onready var chose_starter: BoxContainer = $ChoseStarter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_button_down() -> void:
	get_tree().quit()


func _on_play_button_button_down() -> void:
	for i in 3:
		var control = Control.new()
		var new_starter = starter_scene.instantiate()
		control.add_child(new_starter)
		chose_starter.add_child(control)
