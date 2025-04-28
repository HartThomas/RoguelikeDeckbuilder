extends Node2D
var owner_of_status_bar : String = 'enemy'
@onready var box_container: BoxContainer = $BarSprite/BoxContainer

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
		var sprite =  load("res://art/%s.png" % [status.to_lower()])
		var sprite2d = TextureRect.new()
		sprite2d.texture = sprite
		sprite2d.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		box_container.add_child(sprite2d)
