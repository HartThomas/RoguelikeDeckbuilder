extends Resource
class_name Enemy

@export var hit = 3
@export var block = 3
@export var heal = 3
@export var possible_actions : Array = [{'hit':hit}, {'block':block}, {'heal':heal}]

func which_action_shall_i_take() -> Dictionary:
	return  possible_actions.pick_random()
