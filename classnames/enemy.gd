extends Resource
class_name Enemy

@export var enemy_name :String
@export var hit: int
@export var block : int
@export var heal :int 
@export var max_health: int
@export var starting_health: int
@export var starting_block: int
@export var burn_amount:int

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
