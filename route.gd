extends Sprite2D
var animation
@onready var shader = get_material()
signal route_clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation = $AnimationPlayer
	if shader:
		shader = shader.duplicate()
		shader.set('shader_parameter/outline_width', 0.0)
		set_material(shader)
	route_clicked.connect(get_parent().get_parent().route_chosen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	animation.play('bounce')
	shader.set('shader_parameter/outline_width', 5.0)

func _on_area_2d_mouse_exited() -> void:
	animation.stop()
	shader.set('shader_parameter/outline_width', 0.0)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			route_clicked.emit()
