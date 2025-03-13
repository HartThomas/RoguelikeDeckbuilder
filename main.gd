extends Node2D
@onready var screen: CanvasGroup = $Screen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Screen/Battle.battle_over.connect(battle_over)
	var shader = screen.get_material()
	shader.set_shader_parameter('blur_power', 0.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func route_chosen() -> void :
	$Screen/Adventure.start_battle()
	$Screen/Battle.start_battle()
	$Screen/Battle.battle_over.connect(end_battle_blur)

func battle_over()->void:
	end_battle_blur()
	#$Screen/Battle.end_battle()
	#$Screen/Adventure.end_battle()

func end_battle_blur() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(screen.get_material(), "shader_parameter/blur_power", 0.05, 1.0)
