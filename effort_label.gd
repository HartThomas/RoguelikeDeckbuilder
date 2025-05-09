extends Label


@export var label_text: String = name.format([''], 'EffortLabel') if not name.format([''], 'EffortLabel') == '' else "Physical"
var tooltip_instance: Label

#@onready var tooltip_scene = preload("res://effort_tooltip.tscn")

func _ready():
	connect_signals()

func connect_signals()->void:
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

func _on_mouse_entered():
	var tooltip_scene = preload("res://effort_tooltip.tscn")
	tooltip_instance = tooltip_scene.instantiate()
	tooltip_instance.text = label_text
	var global_pos = get_global_position()
	tooltip_instance.global_position = global_pos + Vector2(0, -30)  # Adjust as needed
	get_tree().root.add_child(tooltip_instance)  # Add to root so it floats

func _on_mouse_exited():
	if tooltip_instance:
		tooltip_instance.queue_free()
		tooltip_instance = null
