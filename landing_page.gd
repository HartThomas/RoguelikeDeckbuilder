extends Control

@export var starter_scene : PackedScene
@export var main_scene : PackedScene
@export var binder_scene: PackedScene

@onready var chose_starter: BoxContainer = $ChoseStarter

var binder_showing : bool = false
var starter_options_showing : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in BattleManager.starter_options:
		var control = Control.new()
		var new_starter = starter_scene.instantiate()
		new_starter.cards = i.cards
		new_starter.choice_name = i.name
		new_starter.starter_picked.connect(starter_picked)
		control.add_child(new_starter)
		chose_starter.add_child(control)
		control.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_quit_button_button_down() -> void:
	get_tree().quit()

func _on_play_button_button_down() -> void:
	starter_options_showing = !starter_options_showing
	if binder_showing and starter_options_showing:
		_on_card_list_button_button_down()
	if starter_options_showing:
		if chose_starter.get_children().size() > 0:
			for child in chose_starter.get_children():
				child.show()
		else:
			for i in BattleManager.starter_options:
				var control = Control.new()
				var new_starter = starter_scene.instantiate()
				new_starter.cards = i.cards
				new_starter.choice_name = i.name
				new_starter.starter_picked.connect(starter_picked)
				control.add_child(new_starter)
				chose_starter.add_child(control)
	else:
		for child in chose_starter.get_children():
			child.hide()

func starter_picked(choice) -> void: 
	BattleManager.add_cards_to_deck(choice.cards)
	get_tree().change_scene_to_packed(main_scene)

func _on_card_list_button_button_down() -> void:
	binder_showing = !binder_showing
	if starter_options_showing and binder_showing:
		_on_play_button_button_down()
	if binder_showing:
		var binder = binder_scene.instantiate()
		add_child(binder)
	else:
		get_children().filter(func (child) : return child.name == 'Binder')[0].queue_free()
