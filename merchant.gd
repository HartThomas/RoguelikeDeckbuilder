extends Node2D
var merchant_stats: Merchant
signal add
signal remove
signal upgrade
signal heal
#@export var 
@onready var remove_button: Button = $RemoveButton
@onready var add_button: Button = $AddButton
@onready var upgrade_button: Button = $UpgradeButton
@onready var heal_button: Button = $HealButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not merchant_stats.add_card_available:
		add_button.queue_free()
	if not merchant_stats.heal_amount > 0:
		heal_button.queue_free()
	else:
		var new_text = "Heal for %s" % [str(merchant_stats.heal_amount)]
		heal_button.text = new_text
	if not merchant_stats.upgrade_card_available:
		upgrade_button.queue_free()
	if not merchant_stats.remove_card_available:
		remove_button.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_remove_button_button_down() -> void:
	remove.emit()


func _on_add_button_button_down() -> void:
	add.emit()


func _on_upgrade_button_button_down() -> void:
	upgrade.emit()


func _on_heal_button_button_down() -> void:
	if BattleManager.player.max_health - BattleManager.player.health > merchant_stats.heal_amount:
		BattleManager.player.health += merchant_stats.heal_amount
	else:
		BattleManager.player.health = BattleManager.player.max_health
	heal.emit()
