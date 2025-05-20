extends Node2D
var owner_of_status_bar : String = 'enemy'
@onready var box_container: BoxContainer = $BarSprite/BoxContainer
var tooltip_instance: Label
@onready var bar_sprite: Sprite2D = $BarSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_status_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_status_bar() -> void:
	if BattleManager[owner_of_status_bar].status_list.size() == 0:
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
		print(shape.shape)
		area.mouse_entered.connect(sprite_hovered.bind(area))
		area.mouse_exited.connect(sprite_unhovered)
		area.add_child(shape)
		box_container.add_child(area)

func sprite_hovered(area) -> void:
	print('hovered')
	var tooltip_scene = preload("res://effort_tooltip.tscn")
	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.text = 'Burn: %s' % [get_parent().enemy.burn_amount]
	#var global_pos = get_global_position()
	#print(position, global_pos)
	tooltip_instance.global_position = area.get_children()[0].position + Vector2(0, -30)
	get_tree().root.add_child(tooltip_instance)
	print(tooltip_instance.position, area.get_children()[0].position)

func sprite_unhovered()-> void:
	print('unhovered')
	if tooltip_instance:
		tooltip_instance.queue_free()
		tooltip_instance = null
