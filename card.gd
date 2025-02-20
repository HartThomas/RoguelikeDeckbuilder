extends Area2D
var is_dragging : bool = false
var mouse_offset :Vector2
var delay = 0
@export var card_info : Resource
signal clicked(input)
signal released(input)
var in_hand : bool = true
var in_deck : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_dragging and self.has_meta("target_position") and self.get_meta("target_position") != self.position:
		self.position = self.position.lerp(self.get_meta("target_position"), 5 * delta)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
			mouse_offset = get_global_mouse_position() - global_position
		else:
			released.emit(self)
			is_dragging = false

func _physics_process(delta):
	if is_dragging:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", get_global_mouse_position()-mouse_offset, delay * delta)
