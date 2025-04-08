extends Area2D
var is_dragging : bool = false
var mouse_offset :Vector2
var delay = 0
@export var card_info : Resource
@export var hover_smoothness : float = 5.0 
signal clicked(input)
signal released(input)
signal add_to_deck(input)
signal mouseEntered(input, entered)
var in_hand : bool = true
var in_deck : bool = true
var temporary_instance : bool = true
var face_up : bool = false
var face_up_texture = preload('res://art/card.png')
var face_down_texture = preload("res://art/card back.png")
var end_of_battle_selecting: bool = false
var mouse_hovering :bool = false
var target_hovering : float = 0.0
var hovering : float = 0.0
@onready var animation = $AnimationPlayer
@onready var card: Area2D = $"."
@onready var canvas_layer: Node2D = $BackBufferCopy/CanvasLayer
var rng = RandomNumberGenerator.new()
@onready var shield_label: Label = $BackBufferCopy/CanvasLayer/Sprite2D/Shield/ShieldLabel
@onready var damage_label: Label = $BackBufferCopy/CanvasLayer/Sprite2D/Damage/DamageLabel
@onready var sprite_2d: Sprite2D = $BackBufferCopy/CanvasLayer/Sprite2D
@onready var name_label: Label = $BackBufferCopy/CanvasLayer/Sprite2D/Name
@onready var damage: Sprite2D = $BackBufferCopy/CanvasLayer/Sprite2D/Damage
@onready var shield: Sprite2D = $BackBufferCopy/CanvasLayer/Sprite2D/Shield

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage.visible = false
	shield.visible = false
	var new_shader = load("res://shaders/combined.gdshader")
	var duplicated_shader = new_shader.duplicate()
	sprite_2d.material = ShaderMaterial.new()
	#duplicated_shader.set_shader_parameter("rand_seed", seed)
	sprite_2d.material.set('shader', duplicated_shader)
	sprite_2d.material.set('shader_parameter/width', 0)
	var seed = randi() % 1000
	sprite_2d.material.set('shader_parameter/rand_seed', seed)
	#canvas_layer.material.set('shader_parameter/width', 0)

func _process(delta: float) -> void:
	if not is_dragging and self.has_meta("target_position") and self.get_meta("target_position") != self.position:
		self.position = self.position.lerp(self.get_meta("target_position"), 5 * delta)
	if not in_deck:
		if get_parent().hand.has(self):
			self.scale = Vector2(2,2)
		else:
			self.scale = Vector2(1,1)
	var mouse_pos1 = get_global_mouse_position()
	var shader = sprite_2d.get_material()
	shader.set_shader_parameter('mouse_screen_pos',mouse_pos1)
	if mouse_hovering:
		target_hovering = 1.0
	else:
		target_hovering = 0.0
	
	hovering = lerp(hovering, target_hovering, hover_smoothness * delta)
	shader.set_shader_parameter("hovering", hovering)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if end_of_battle_selecting:
				add_to_deck.emit(self)
			else:
				clicked.emit(self)
				mouse_offset = get_global_mouse_position() - global_position
			
		else:
			released.emit(self)
			is_dragging = false

func _physics_process(delta):
	if is_dragging:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", get_global_mouse_position()-mouse_offset, delay * delta)


func _on_mouse_entered() -> void:
	if not temporary_instance:
		mouseEntered.emit(self, true)
	var shader = sprite_2d.get_material()
	shader.set_shader_parameter('width', 20)
	mouse_hovering  = true

func _on_mouse_exited() -> void:
	if not temporary_instance:
		mouseEntered.emit(self, false)
	var shader = sprite_2d.get_material()
	shader.set_shader_parameter('width', 0)
	mouse_hovering  = false

func trigger_card_flip_animation()->void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var shader_material = sprite_2d.get_material()
	tween.tween_method(set_shader_param_for_flip_up, 0.0, 180.0, 0.5)

func set_shader_param_for_flip_up(value):
	var shader_material = sprite_2d.get_material()
	shader_material.set_shader_parameter('y_rot', value)
	if value >= 90.0 and !face_up:
		card_flip()

func trigger_card_flip_to_deck_animation()->void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var shader_material = sprite_2d.get_material()
	tween.tween_method(set_shader_param_for_flip_down, 0.0, 180.0, 0.5)
	
func set_shader_param_for_flip_down(value):
	var shader_material = sprite_2d.get_material()
	shader_material.set_shader_parameter('y_rot', value)
	if value >= 90.0 and face_up:
		card_flip()

func card_flip() -> void:
	face_up = !face_up
	var face_up_texture = load('res://art/card.png')
	if face_up:
		sprite_2d.texture = face_up_texture
		name_label.text = card_info.card_name
		if card_info.attack > 0:
			damage.visible = true
			damage_label.text = str(card_info.attack)
		if card_info.block > 0:
			shield.visible = true
			shield_label.text = str(card_info.block)
	else:
		sprite_2d.texture = face_down_texture
		name_label.text = ''
		damage.visible = false
		shield.visible = false
