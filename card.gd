extends Area2D
var is_dragging : bool = false
var is_shaking : bool = false
var is_forgetting : bool = false
var mouse_offset :Vector2
var delay = 0
@export var card_info : Resource
@export var hover_smoothness : float = 5.0 
signal clicked(input)
signal released(input)
signal add_to_deck(input)
signal mouseEntered(input, entered)
signal forget_finished(input)
signal card_zoom(input)
var in_hand : bool = true
var in_deck : bool = true
var in_binder: bool = false
var in_card_zoom: bool = false
var temporary_instance : bool = true
var face_up : bool = false
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
	card_zoom.connect(BattleManager.card_zoom)
	if in_binder:
		card_flip()
		scale = Vector2(0.75,0.75)
	elif in_card_zoom:
		card_flip()
		scale = Vector2(1,1)
	else:
		scale = Vector2(0.75,0.75)

func _process(delta: float) -> void:
	if not is_dragging and self.has_meta("target_position") and self.get_meta("target_position") != self.position and not is_shaking and not is_forgetting:
		self.position = self.position.lerp(self.get_meta("target_position"), 5 * delta)
	if not in_deck:
		if get_parent().hand.has(self):
			self.scale = Vector2(0.75,0.75)
		else:
			self.scale = Vector2(0.5,0.5)
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
	var card_route = "res://art/%s card.png" % [ 
	"fire" if card.card_cost.fire_effort > 0 
	else "blood" if card.card_cost.blood_effort > 0 
	else "holy" if card.card_cost.holy_effort > 0 
	else "mental" if card.card_cost.mental_effort > 0 
	else "physical"
]
	var texture = load(card_route) as Texture2D
	var base_image = texture.get_image()
	var label_image = await make_label_image(card.card_name)
	var max_label_width = 80
	if label_image.get_width() > max_label_width:
		
		var scaled_image = Image.new()
		scaled_image.copy_from(label_image)
		scaled_image.resize(max_label_width, label_image.get_height(), Image.INTERPOLATE_LANCZOS)
		label_image = scaled_image
	var image_texture = ImageTexture.create_from_image(label_image)
	var label_pos_x = 13 + ((base_image.get_width() - label_image.get_width()) / 2.0) - (base_image.get_width() / 2.0 - 13)
	var name_position = Vector2(15, 0)
	base_image.blend_rect(label_image, Rect2(Vector2.ZERO, label_image.get_size()), name_position)
	if card.attack != 0:
		var attack_texture = load("res://art/attack.png")
		var attack_image = attack_texture.get_image()
		base_image.blend_rect(attack_image, Rect2(Vector2.ZERO, attack_image.get_size()), Vector2(48,64 ))
		var attack_amount_label = await make_label_image(str(card.attack), 10, true)
		base_image.blend_rect(attack_amount_label, Rect2(Vector2.ZERO, attack_amount_label.get_size()), Vector2(56,62 ))
	if card.block != 0:
		var block_texture = load('res://art/block.png')
		var block_image = block_texture.get_image()
		base_image.blend_rect(block_image, Rect2(Vector2.ZERO, block_image.get_size()), Vector2(18,64 ))
		var block_amount_label = await make_label_image(str(card.block), 10, true)
		base_image.blend_rect(block_amount_label, Rect2(Vector2.ZERO, block_amount_label.get_size()), Vector2(26,62 ))
	if card.card_text.length() > 0:
		var card_text = await make_label_image(card.card_text, 10 )
		base_image.blend_rect(card_text, Rect2(Vector2.ZERO, card_text.get_size()),Vector2(15,45 ))
	for cost in card.card_cost:
		if card.card_cost[cost] > 0:
			var effort_path = cost.replace('_', ' ')
			var effort_texture = load("res://art/%s.png" % [effort_path])
			var effort_image = effort_texture.get_image()
			var target_size = Vector2i(24, 24)
			effort_image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
			base_image.blend_rect(effort_image, Rect2(Vector2.ZERO, effort_image.get_size()), Vector2(68,10 ))
	var tex = ImageTexture.create_from_image(base_image)
	
	return tex

func make_label_image(text: String, font_size : int = 10, small = false) -> Image:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override('font_color', Color.DARK_RED)
	label.add_theme_font_size_override('font_size', font_size)
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	#label.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var temp_font = label.get_theme_font("font")
	var text_size = temp_font.get_string_size(text)
	label.custom_minimum_size = Vector2(70,80)
	
	if small:
		label.custom_minimum_size = Vector2(10,10)
	
	var viewport = SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.size = Vector2(70,80)
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and not in_card_zoom and face_up:
			card_zoom.emit(self)

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
	tween.tween_method(set_shader_param_for_flip_up, 180.0, 0.0, 0.5)

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
	is_forgetting = true
	var tween = get_tree().create_tween()
	tween.tween_method(set_burn_amount,0.0,1.0,1.0)
	await tween.finished
	is_forgetting = false
	forget_finished.emit(self)

func set_burn_amount(value):
	var shader_material = $BackBufferCopy/CanvasLayer.get_material()
	shader_material.set_shader_parameter('burn_amount', value)

func shake_card():
	is_shaking = true
	var original_position = position
	var tween = get_tree().create_tween()
	var shake_strength = 10
	var duration = 0.05
	await tween.tween_property(self, "position:x", original_position.x - shake_strength, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.tween_property(self, "position:x", original_position.x + shake_strength, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.tween_property(self, "position:x", original_position.x, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	is_shaking = false
