extends Sprite2D
@onready var animation = $AnimationPlayer
@onready var shader = get_material()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if shader:
		shader = shader.duplicate()
		shader.set_shader_parameter('outline_width', 0.0)
		set_material(shader)
		print(get_material())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	animation.play('bounce')
	shader.set_shader_parameter('outline_width', 5.0)
	print("Hovered: ", self.name, " | Width:", shader.get_shader_parameter("outline_width"))

func _on_area_2d_mouse_exited() -> void:
	animation.stop()
	shader.set_shader_parameter('outline_width', 0.0)
	print("Hovered: ", self.name, " | Width:", shader.get_shader_parameter("outline_width"))
