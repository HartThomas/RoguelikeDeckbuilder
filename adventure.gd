extends Node2D
@export var route_scene : PackedScene 
var stage :int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var center_x = 600
	var spacing = 212
	var total_routes = CampaignManager.campaign_data.stages[stage].routes.size()
	for i in total_routes:
		var new_route = route_scene.instantiate()
		var offset = (i - (total_routes - 1) / 2.0) * spacing
		new_route.position.x = center_x + offset
		new_route.assign_stats(CampaignManager.campaign_data.stages[stage].routes[i].event)
		add_child(new_route)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_battle()->void:
	hide()

func end_battle()->void:
	show()
