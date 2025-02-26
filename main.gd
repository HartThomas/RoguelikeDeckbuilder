extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Battle.battle_over.connect(battle_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func route_chosen() -> void :
	$Adventure.start_battle()
	$Battle.start_battle()

func battle_over()->void:
	$Battle.end_battle()
	$Adventure.end_battle()
