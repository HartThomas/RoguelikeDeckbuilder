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
signal forget_finished(input)
var in_hand : bool = true
var in_deck : bool = true
var temporary_instance : bool = true
var face_up : bool = false
var face_up_texture = preload('res://art/pixel card.png')
var face_down_texture = preload("res://art/pixel card back.png")
var end_of_battle_selecting: bool = false
var mouse_hovering :bool = false
var target_hovering : float = 0.0
var hovering : float = 0.0
@onready var animation = $AnimationPlayer
@onready var card: Area2D = $"."
@onready var canvas_layer: Node2D = $BackBufferCopy/CanvasLayer
var rng = RandomNumberGenerator.new()
@onready var shield_label: Label = $BackBufferCopy/CanvasLayer/Shield/ShieldLabel
@onready var damage_label: Label = $BackBufferCopy/CanvasLayer/Damage/DamageLabel
@onready var sprite_2d: Sprite2D = $BackBufferCopy/CanvasLayer/Sprite2D
@onready var name_label: Label = $BackBufferCopy/CanvasLayer/Name
@onready var damage: Sprite2D = $BackBufferCopy/CanvasLayer/Damage
@onready var shield: Sprite2D = $BackBufferCopy/CanvasLayer/Shield
const PIXEL_FONT = preload("res://art/pixel font.ttf")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage.visible = false
	shield.visible = false
	var new_shader = load("res://shaders/combined.gdshader")
	var duplicated_shader = new_shader.duplicate()
	sprite_2d.material = ShaderMaterial.new()
	sprite_2d.material.set('shader', duplicated_shader)
	sprite_2d.material.set('shader_parameter/width', 0)
	var seed = randi() % 1000
	sprite_2d.material.set('shader_parameter/rand_seed', seed)
	var canvas_shader = load("res://shaders/burn.gdshader")
	var duplicated_canvas_shader = canvas_shader.duplicate()
	$BackBufferCopy/CanvasLayer.material = ShaderMaterial.new()
	$BackBufferCopy/CanvasLayer.material.set('shader', duplicated_canvas_shader)
	var noise = NoiseTexture2D.new()
	noise.noise = FastNoiseLite.new()
	$BackBufferCopy/CanvasLayer.material.set_shader_parameter('noise_texture', noise)

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

func generate_texture(card: CardStats) -> ImageTexture:
	var base_image = Image.new()
	base_image.load('res://art/pixel card.png')
	var label_image = await make_label_image(card.card_name)
	var max_label_width = 40
	if label_image.get_width() > max_label_width:
		var scaled_image = Image.new()
		scaled_image.copy_from(label_image)
		scaled_image.resize(max_label_width, label_image.get_height(), Image.INTERPOLATE_LANCZOS)
		label_image = scaled_image
	var image_texture = ImageTexture.create_from_image(label_image)
	var label_pos_x = 13 + ((base_image.get_width() - label_image.get_width()) / 2.0) - (base_image.get_width() / 2.0 - 13)
	var name_position = Vector2(13, 15) 
	base_image.blend_rect(label_image, Rect2(Vector2.ZERO, label_image.get_size()), name_position)
	if card.attack != 0:
		var attack_texture = Image.new()
		attack_texture.load("res://art/attack.png")
		base_image.blend_rect(attack_texture, Rect2(Vector2.ZERO, attack_texture.get_size()), Vector2(24,32 ))
		var attack_amount_label = await make_label_image(str(card.attack))
		base_image.blend_rect(attack_amount_label, Rect2(Vector2.ZERO, attack_amount_label.get_size()), Vector2(28,31 ))
	if card.block != 0:
		var block_texture = Image.new()
		block_texture.load('res://art/block.png')
		base_image.blend_rect(block_texture, Rect2(Vector2.ZERO, block_texture.get_size()), Vector2(9,32 ))
		var block_amount_label = await make_label_image(str(card.block))
		base_image.blend_rect(block_amount_label, Rect2(Vector2.ZERO, block_amount_label.get_size()), Vector2(13,31 ))
	if card.card_text.length() > 0:
		var card_text = await make_label_image(card.card_text, 5)
		print(card_text.get_size())
		base_image.blend_rect(card_text, Rect2(Vector2.ZERO, card_text.get_size()),Vector2(7,0 ))
		
	#base_image.flip_x()
	var tex = ImageTexture.create_from_image(base_image)
	return tex

func make_label_image(text: String, font_size : int = 10) -> Image:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override('font_color', Color.DARK_RED)
	label.add_theme_font_size_override('font_size', font_size)
	label.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
	# Measure text size using FontMetrics
	var temp_font = label.get_theme_font("font")
	var text_size = temp_font.get_string_size(text)
	
	if font_size != 10:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(35,80)
	# Figure out if we need to scale horizontally
	#var target_width = max_width
	#if text_size.x > target_width:
		#var scale_x = target_width / text_size.x
		#label.scale = Vector2(scale_x * 0.7, 0.3)
	#else:
		#label.scale = Vector2(0.3, 0.3)
#
	## Set container size to base width, text height
	#var container_width = target_width
	#var container_height = int(text_size.y * 0.3) + 2  # give a bit of breathing room
	#label.custom_minimum_size = Vector2(container_width, container_height)
	
	var viewport = SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.size = Vector2(35,80)
	viewport.transparent_bg = true
	viewport.add_child(label)
	add_child(viewport)

	await RenderingServer.frame_post_draw

	var image = viewport.get_texture().get_image()
	remove_child(viewport)
	return image

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
	shader.set_shader_parameter('width', 1.2)
	mouse_hovering  = true

func _on_mouse_exited() -> void:
	if not temporary_instance:
		mouseEntered.emit(self, false)
	var shader = sprite_2d.get_material()
	shader.set_shader_parameter('width', 0)
	mouse_hovering  = false

func trigger_card_flip_animation()->void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#var shader_material = sprite_2d.get_material()
	tween.tween_method(set_shader_param_for_flip_up, 180.0, 0.0, 0.5)
	#tween.finished.connect(card_flip)
	#await tween.finished
	#var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#tween2.tween_method(set_shader_param_for_flip_up, 90.0, 0.0, 0.5)

func set_shader_param_for_flip_up(value):
	var shader_material = sprite_2d.get_material()
	shader_material.set_shader_parameter('y_rot', value)
	if value <= 90.0 and !face_up:
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
	if face_up:
		
		sprite_2d.texture =  await generate_texture(card_info)
		var font = load("res://art/pixel font.ttf")
		#sprite_2d.draw_string(font, Vector2(20,20), card_info.card_name)
		#if card_info.attack > 0:
			#damage.visible = true
			#damage_label.text = str(card_info.attack)
		#if card_info.block > 0:
			#shield.visible = true
			#shield_label.text = str(card_info.block)
	else:
		sprite_2d.texture = face_down_texture
		name_label.text = ''
		damage.visible = false
		shield.visible = false

func forget_card() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(set_burn_amount,0.0,1.0,1.0)
	await tween.finished
	forget_finished.emit(self)

func set_burn_amount(value):
	var shader_material = $BackBufferCopy/CanvasLayer.get_material()
	print(value)
	print(shader_material)
	shader_material.set_shader_parameter('burn_amount', value)
