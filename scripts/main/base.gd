extends Node2D

## 기지 씬 스크립트
## 퀘스트 보드, 제작대, 스태시, 레이드 출발 관리

@onready var quest_panel: Control = $UI/QuestPanel
@onready var craft_panel: Control = $UI/CraftPanel
@onready var stash_panel: Control = $UI/StashPanel
@onready var loadout_panel: Control = $UI/LoadoutPanel
@onready var player_info: Control = $UI/PlayerInfo


func _ready() -> void:
	_update_player_info()
	_hide_all_panels()


func _hide_all_panels() -> void:
	quest_panel.visible = false
	craft_panel.visible = false
	stash_panel.visible = false
	loadout_panel.visible = false


func _update_player_info() -> void:
	var level_label = player_info.get_node("LevelLabel")
	var xp_bar = player_info.get_node("XPBar")
	var kills_label = player_info.get_node("KillsLabel")
	var raids_label = player_info.get_node("RaidsLabel")

	level_label.text = "Lv. %d" % GameState.player_level
	xp_bar.max_value = GameState.xp_to_next_level
	xp_bar.value = GameState.player_xp
	kills_label.text = "Total Kills: %d" % GameState.total_kills
	raids_label.text = "Raids: %d" % GameState.successful_raids


#region 버튼 콜백
func _on_quest_button_pressed() -> void:
	_hide_all_panels()
	quest_panel.visible = true
	quest_panel.refresh()


func _on_craft_button_pressed() -> void:
	_hide_all_panels()
	craft_panel.visible = true
	craft_panel.refresh()


func _on_stash_button_pressed() -> void:
	_hide_all_panels()
	stash_panel.visible = true
	stash_panel.refresh()


func _on_loadout_button_pressed() -> void:
	_hide_all_panels()
	loadout_panel.visible = true
	loadout_panel.refresh()


func _on_raid_button_pressed() -> void:
	GameState.start_field_raid()


func _on_menu_button_pressed() -> void:
	GameState.return_to_menu()


func _on_close_panel_pressed() -> void:
	_hide_all_panels()
#endregion
