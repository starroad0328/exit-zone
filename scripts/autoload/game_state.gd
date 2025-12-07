extends Node

## 게임 상태 관리 오토로드
## 레이드 단계, 씬 전환, 승패 처리

enum Phase { MENU, FIELD_RAID, DEFENSE_RAID, RESULT }

var current_phase: Phase = Phase.MENU
var raid_success: bool = false
var player_dead: bool = false

# 웨이브 관련
var current_wave: int = 0
var enemies_remaining: int = 0

signal phase_changed(new_phase: Phase)
signal raid_completed(success: bool)
signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)


func _ready() -> void:
	pass


## 필드 레이드 시작
func start_field_raid() -> void:
	current_phase = Phase.FIELD_RAID
	raid_success = false
	player_dead = false
	InventoryManager.clear_raid_inventory()
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file("res://scenes/main/field_raid.tscn")


## 디펜스 레이드 시작 (필드 추출 성공 시)
func start_defense_raid() -> void:
	current_phase = Phase.DEFENSE_RAID
	current_wave = 0
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file("res://scenes/main/defense_raid.tscn")


## 레이드 성공
func complete_raid() -> void:
	raid_success = true
	current_phase = Phase.RESULT
	InventoryManager.transfer_to_stash()
	phase_changed.emit(current_phase)
	raid_completed.emit(true)
	get_tree().change_scene_to_file("res://scenes/main/result_screen.tscn")


## 레이드 실패 (플레이어 사망)
func fail_raid() -> void:
	player_dead = true
	raid_success = false
	current_phase = Phase.RESULT
	InventoryManager.clear_raid_inventory()
	phase_changed.emit(current_phase)
	raid_completed.emit(false)
	get_tree().change_scene_to_file("res://scenes/main/result_screen.tscn")


## 메뉴로 돌아가기
func return_to_menu() -> void:
	current_phase = Phase.MENU
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file("res://scenes/main/menu.tscn")


## 웨이브 시작
func start_wave(wave_num: int, enemy_count: int) -> void:
	current_wave = wave_num
	enemies_remaining = enemy_count
	wave_started.emit(wave_num)


## 적 처치 시 호출
func enemy_killed() -> void:
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		wave_completed.emit(current_wave)
