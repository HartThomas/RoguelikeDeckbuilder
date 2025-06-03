extends Resource
class_name Enemy

@export var enemy_name :String
@export var hit: int
@export var block : int
@export var heal :int 
@export var max_health: int
@export var starting_health: int
@export var starting_block: int
@export var burn_amount:int = 0
@export var stun_amount:int = 0
@export var final_boss:bool = false

var action : Callable

func which_action_shall_i_take() -> Dictionary:
	var possible_actions : Array = []
	if hit > 0:
		possible_actions.append({'hit':hit})
	if block > 0:
		possible_actions.append({'block':block})
	if heal > 0:
		possible_actions.append({'heal':heal})
	return  possible_actions.pick_random()

func remove_action() -> void:
	var possible_actions : Array = []
	if hit > 0:
		possible_actions.append('hit')
	if block > 0:
		possible_actions.append('block')
	if heal > 0:
		possible_actions.append('heal')
	print(possible_actions, '1st')
	if possible_actions.is_empty():
		print("No actions to remove.")
		return
	var picked_action = possible_actions.pick_random()
	match picked_action:
		"hit":
			hit = 0
		"block":
			block = 0
		"heal":
			heal = 0
