extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card_container: Control = $CardContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card in card_container.get_children().filter(func (child) : return child.name != 'ChoiceLabel'):
		card.card_flip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	if animation_player:
		animation_player.play('hover')

func _on_mouse_exited() -> void:
	if animation_player.current_animation == "hover" and animation_player.is_playing():
		var time = animation_player.current_animation_position
		animation_player.play("hover", -1, -1.0, true)
		animation_player.seek(time, true)
		animation_player.advance(0)
	else:
		animation_player.play("hover", -1, -1.0, true)
