extends Node2D
@export var route_scene : PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_route = route_scene.instantiate()
	new_route.position.x = 600
	add_child(new_route)
	var new_route2 = route_scene.instantiate()
	new_route2.position.x = 388
	add_child(new_route2)
	var new_route3 = route_scene.instantiate()
	new_route3.position.x = 812
	add_child(new_route3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_battle()->void:
	hide()

func end_battle()->void:
	show()
