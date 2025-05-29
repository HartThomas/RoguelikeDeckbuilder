extends Node2D
var owner_of_status_bar : String = 'enemy'
@onready var box_container: BoxContainer = $BarSprite/BoxContainer
var tooltip_instance: Label
@onready var bar_sprite: Sprite2D = $BarSprite
var tooltip_text = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_status_bar() -> void:
	#if BattleManager[owner_of_status_bar].status_list.size() == 0:
	for child in box_container.get_children():
		child.queue_free()
	for status in BattleManager[owner_of_status_bar].status_list:
		var area = Area2D.new()
		area.set_pickable(true)
		var sprite =  load("res://art/%s.png" % [status.to_lower()])
		var sprite2d = Sprite2D.new()
		sprite2d.texture = sprite
		sprite2d.scale = Vector2(0.5,0.5)
		sprite2d.position += Vector2(5,5)
		area.add_child(sprite2d)
		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = sprite.get_size()
		shape.shape = rect_shape
		#area.mouse_entered.connect(sprite_hovered.bind(area))
		#area.mouse_exited.connect(sprite_unhovered)
		area.add_child(shape)
		var control = Control.new()
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.add_child(area)
		box_container.add_child(control)
	tooltip_text = 'Burn: %s' % [get_parent().enemy.burn_amount] if BattleManager[owner_of_status_bar].status_list.has('flame') else '' 
	tooltip_text += '  Stunned: %s turn' % [get_parent().enemy.stun_amount] if BattleManager[owner_of_status_bar].status_list.has('stun') else ''
	tooltip_text += '  Hemorrhage: %s' % [get_parent().hemorrhage_amount] if BattleManager[owner_of_status_bar].status_list.has('hemorrhage') else ''

func _on_box_container_mouse_entered() -> void:
	var tooltip_scene = preload("res://effort_tooltip.tscn")
	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.text = tooltip_text
	tooltip_instance.global_position = bar_sprite.position + Vector2(-200, -30)
	get_tree().root.add_child(tooltip_instance)


func _on_box_container_mouse_exited() -> void:
	if tooltip_instance:
		tooltip_instance.queue_free()
		tooltip_instance = null
