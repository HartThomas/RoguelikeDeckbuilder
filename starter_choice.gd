extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card_container: Control = $CardContainer
@onready var choice_label: Label = $CardContainer/ChoiceLabel
@onready var texture_rect: TextureRect = $TextureRect
signal starter_picked(choice)

var cards = ['Block', 'Block', 'Block']
var choice_name : String = 'Holy'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	choice_label.text = choice_name
	var index = 0
	for card in card_container.get_children().filter(func (child) : return child.name != 'ChoiceLabel'):
		var card_path = "res://resources/%s.tres" % [cards[index].to_lower()]
		var card_details = load(card_path)
		card.card_info = card_details
		card.card_flip()
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	if animation_player:
		animation_player.play('hover')
	texture_rect.visible = true

func _on_mouse_exited() -> void:
	texture_rect.visible = false
	if animation_player.current_animation == "hover" and animation_player.is_playing():
		var time = animation_player.current_animation_position
		animation_player.play("hover", -1, -1.0, true)
		animation_player.seek(time, true)
		animation_player.advance(0)
	else:
		animation_player.play("hover", -1, -1.0, true)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			starter_picked.emit(self)
