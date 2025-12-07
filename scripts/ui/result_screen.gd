extends Control

## 결과 화면 스크립트

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var items_label: Label = $VBoxContainer/ItemsLabel
@onready var xp_label: Label = $VBoxContainer/XPLabel


func _ready() -> void:
	if GameState.raid_success:
		status_label.text = "레이드 성공!"
		status_label.modulate = Color.GREEN
		_show_raid_stats()
		_show_acquired_items()
	else:
		status_label.text = "레이드 실패..."
		status_label.modulate = Color.RED
		if stats_label:
			stats_label.text = "처치: %d" % GameState.kills_this_raid
		items_label.text = "모든 아이템을 잃었습니다."
		if xp_label:
			xp_label.text = ""


func _show_raid_stats() -> void:
	if stats_label:
		stats_label.text = "처치: %d | 생존 레이드: %d" % [GameState.kills_this_raid, GameState.successful_raids]
	if xp_label:
		var xp_earned = 50 + GameState.kills_this_raid * 5
		xp_label.text = "+%d XP | Lv.%d (%d/%d)" % [
			xp_earned,
			GameState.player_level,
			GameState.player_xp,
			GameState.xp_to_next_level
		]


func _show_acquired_items() -> void:
	var items_text = "스태시에 저장됨:\n"
	var stash = InventoryManager.stash

	if stash["weapons"].size() > 0:
		items_text += "무기: %d개\n" % stash["weapons"].size()

	var consumables = []
	if stash["ammo_9mm"] > 0:
		consumables.append("9mm: %d" % stash["ammo_9mm"])
	if stash["ammo_556"] > 0:
		consumables.append("5.56: %d" % stash["ammo_556"])
	if stash["bandage"] > 0:
		consumables.append("붕대: %d" % stash["bandage"])
	if stash["energy_drink"] > 0:
		consumables.append("에너지: %d" % stash["energy_drink"])

	if consumables.size() > 0:
		items_text += ", ".join(consumables) + "\n"

	var materials = []
	if stash["scrap_metal"] > 0:
		materials.append("고철: %d" % stash["scrap_metal"])
	if stash["gun_parts"] > 0:
		materials.append("부품: %d" % stash["gun_parts"])
	if stash["cloth"] > 0:
		materials.append("천: %d" % stash["cloth"])
	if stash["chemicals"] > 0:
		materials.append("화학: %d" % stash["chemicals"])

	if materials.size() > 0:
		items_text += ", ".join(materials)

	items_label.text = items_text


func _on_continue_pressed() -> void:
	GameState.return_to_base()
