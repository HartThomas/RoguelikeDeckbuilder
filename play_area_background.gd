extends Sprite2D



var glow_power = 0.0
var speed = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	glow_power += delta * speed
	if glow_power >=0.5 and speed > 0 or glow_power <= 0.0 and speed < 0:
		speed *= -1.0
	self.get_material().set_shader_parameter('glow_strength', glow_power)

func start_shader() -> void:
	var shader = get_material()
	shader.set_shader_parameter('hovered',true)
	speed = 0.75

func stop_shader() -> void:
	var shader = get_material()
	shader.set_shader_parameter('hovered',false)
	speed = 0.0
