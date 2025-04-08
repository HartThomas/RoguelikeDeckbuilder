extends Node

var campaign_data = {
	"stages": [
		{
			"name": "Forest of Trials",
			"routes": [
				{ "type": "friendly", "event": "Healer's Hut", "reward": "Heal 20 HP" },
				{ "type": "enemy", "event": "Bandit Raid", "reward": "New Card" }
			],
			"boss": { "name": "Ancient Treant", "hp": 100, "attack": 15 },
			"player_choice": null
		},
		{
			"name": "Cursed Swamp",
			"routes": [
				{ "type": "friendly", "event": "Mystic Oracle", "reward": "Upgrade Card" },
				{ "type": "enemy", "event": "Dark Cultists", "reward": "New Card" }
			],
			"boss": { "name": "Swamp Horror", "hp": 120, "attack": 20 },
			"player_choice": null
		},
		{
			"name": "Demon's Gate",
			"routes": [
				{ "type": "friendly", "event": "Ancient Library", "reward": "Draw 2 Extra Cards Next Fight" },
				{ "type": "enemy", "event": "Infernal Knight", "reward": "Legendary Card" }
			],
			"boss": { "name": "Demon King", "hp": 150, "attack": 30 },
			"player_choice": null
		}
	]
}

func save_campaign_progress():
	var save_file = FileAccess.open("user://campaign_save.json", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(campaign_data))
	save_file.close()

func load_campaign_progress():
	if FileAccess.file_exists("user://campaign_save.json"):
		var save_file = FileAccess.open("user://campaign_save.json", FileAccess.READ)
		var data = JSON.parse_string(save_file.get_as_text())
		if data:
			campaign_data = data
		save_file.close()

func select_route(stage_index, route_index):
	campaign_data["stages"][stage_index]["player_choice"] = route_index
	save_campaign_progress()
