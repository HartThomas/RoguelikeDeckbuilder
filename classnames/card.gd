extends Resource
class_name CardStats

@export var card_name: String 
@export var attack: int 
@export var block: int 
@export var position: Vector2 = Vector2(103, 536)
@export var texture: CompressedTexture2D
@export var card_text: String
@export var card_cost: Dictionary = {physical_effort = 1, fire_effort = 0, holy_effort = 0, blood_effort = 0}
var effect: Callable = func(): pass


func when_played() -> void:
	if effect:
		effect.call()
