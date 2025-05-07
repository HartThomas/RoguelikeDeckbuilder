extends Node2D
@onready var screen: CanvasGroup = $Screen
@onready var battle: Node2D = $Screen/Battle
@export var victory_scene : PackedScene
@export var merchant_scene : PackedScene
@export var remove_scene : PackedScene
@export var upgrade_scene : PackedScene
var merchant_ref 

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
		$Screen/Battle.enemy = route_stats.enemy
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


func end_battle_blur() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(screen.get_material(), "shader_parameter/blur_power", 0.05, 1.0)

func card_picked() -> void:
	$Screen/Battle.end_battle()
	$Screen/Adventure.stage += 1
	$Screen/Adventure.end_battle()
	var tween = get_tree().create_tween()
	tween.tween_property(screen.get_material(), "shader_parameter/blur_power", 0.0, 1.0)

func merchant_route_clicked(route_stats: Route)-> void:
	$Screen/Adventure.hide()
	var new_scene = merchant_scene.instantiate()
	new_scene.merchant_stats = route_stats.merchant
	new_scene.add.connect(merchant_add_card_clicked)
	new_scene.remove.connect(merchant_remove_card_clicked)
	new_scene.upgrade.connect(merchant_upgrade_card_clicked)
	new_scene.heal.connect(merchant_heal_clicked)
	add_child(new_scene)
	merchant_ref = new_scene

func merchant_add_card_clicked()-> void:
	pause_scene(merchant_ref)
	var new_scene = victory_scene.instantiate()
	new_scene.card_picked.connect(merchant_card_picked)
	add_child(new_scene)
	
func merchant_card_picked()-> void:
	$Screen/Adventure.show()
	merchant_ref.queue_free()

func merchant_remove_card_clicked()-> void:
	pause_scene(merchant_ref)
	var new_scene = remove_scene.instantiate()
	new_scene.card_picked.connect(merchant_card_picked)
	add_child(new_scene)

func merchant_upgrade_card_clicked() -> void:
	pause_scene(merchant_ref)
	var new_scene = upgrade_scene.instantiate()
	new_scene.card_picked.connect(merchant_card_picked)
	add_child(new_scene)

func merchant_heal_clicked() -> void:
	$Screen/Adventure.show()
	merchant_ref.queue_free()
