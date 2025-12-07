extends Control

## 메인 메뉴 스크립트

@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel


func _ready() -> void:
	_update_display()


func _update_display() -> void:
	if level_label:
		level_label.text = "Lv. %d" % GameState.player_level
	if stats_label:
		stats_label.text = "Kills: %d | Raids: %d" % [GameState.total_kills, GameState.successful_raids]


func _on_start_pressed() -> void:
	GameState.go_to_base()


func _on_continue_pressed() -> void:
	# 저장 데이터가 있으면 기지로, 없으면 새 게임
	GameState.go_to_base()


func _on_new_game_pressed() -> void:
	GameState.reset_save()
	_update_display()


func _on_quit_pressed() -> void:
	get_tree().quit()
