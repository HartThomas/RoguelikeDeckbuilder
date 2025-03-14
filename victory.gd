extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(0,-1000)
	self.position.lerp( Vector2(0,0), 5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
