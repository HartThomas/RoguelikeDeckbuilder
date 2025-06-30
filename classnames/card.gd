extends Resource
class_name CardStats

@export var card_name: String 
@export var attack: int 
@export var block: int 
@export var position: Vector2 = Vector2(62.5, 300)
@export var texture: CompressedTexture2D
@export var card_text: String
@export var card_cost: Dictionary = {physical_effort = 1, fire_effort = 0, holy_effort = 0, blood_effort = 0, mental_effort = 0}
@export var effect: Callable = func(): pass
@export var number_of_times_used :int = 0

func when_played() -> void:
	if effect:
		effect.call()

func to_dict() -> Dictionary:
	return {
		card_name = card_name,
		attack = attack,
		block = block,
		number_of_times_used = number_of_times_used
	}
