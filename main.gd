extends Node2D
@onready var screen: CanvasGroup = $Screen
@onready var battle: Node2D = $Screen/Battle
@export var victory_scene : PackedScene
@export var merchant_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Screen/Battle.battle_over.connect(battle_over)
	var shader = screen.get_material()
	shader.set_shader_parameter('blur_power', 0.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func route_chosen(route_stats: Route) -> void :
	if route_stats.helpful:
		merchant_route_clicked(route_stats)
	else:
		BattleManager.edit_enemy_stats(route_stats.enemy)
		$Screen/Adventure.start_battle()
		$Screen/Battle.start_battle()
		$Screen/Battle.battle_over.connect(end_battle_blur)

func pause_scene(scene) -> void:
	scene.set_process(false)
	scene.set_process_input(false)

func battle_over()->void:
	end_battle_blur()
	pause_scene(battle)
	var new_scene = victory_scene.instantiate()
	new_scene.card_picked.connect(card_picked)
	add_child(new_scene)
	#print(battle.get_children())
	#for card in battle.get_children().filter(func(child): return child.get('card_info')):
		#print(card)
		#pause_scene(card)


func end_battle_blur() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(screen.get_material(), "shader_parameter/blur_power", 0.05, 1.0)

func card_picked() -> void:
	$Screen/Battle.end_battle()
	$Screen/Adventure.end_battle()
	var tween = get_tree().create_tween()
	tween.tween_property(screen.get_material(), "shader_parameter/blur_power", 0.0, 1.0)

func merchant_add_card_clicked()-> void:
	pause_scene(merchant_scene)
	var new_scene = victory_scene.instantiate()
	new_scene.card_picked.connect(card_picked)
	add_child(new_scene)

func merchant_card_picked()-> void:
	pass

func merchant_route_clicked(route_stats: Route)-> void:
	$Screen/Adventure.hide()
	var new_scene = merchant_scene.instantiate()
	new_scene.merchant_stats = route_stats.merchant
	add_child(new_scene)
	
