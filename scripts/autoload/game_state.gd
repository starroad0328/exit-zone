extends Node

## 게임 상태 관리 오토로드
## 레이드 단계, 씬 전환, 승패 처리, 레벨/퀘스트/제작법

enum Phase { MENU, BASE, FIELD_RAID, DEFENSE_RAID, RESULT }

var current_phase: Phase = Phase.MENU
var raid_success: bool = false
var player_dead: bool = false

# 웨이브 관련
var current_wave: int = 0
var enemies_remaining: int = 0

# 레벨/경험치 시스템
var player_level: int = 1
var player_xp: int = 0
var xp_to_next_level: int = 100

# 퀘스트 시스템
var active_quests: Array[Dictionary] = []
var completed_quest_ids: Array[String] = []

# 킬 카운트 (퀘스트용)
var kills_this_raid: int = 0
var total_kills: int = 0
var successful_raids: int = 0

# 제작법 해금
var unlocked_blueprints: Array[String] = ["p1_sidearm", "bandage"]

# 시련(TRIAL) 관련
var trial_active: bool = false

# 저장 파일 경로
const SAVE_PATH = "user://save_data.json"

signal phase_changed(new_phase: Phase)
signal raid_completed(success: bool)
signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)
signal xp_gained(amount: int)
signal level_up(new_level: int)
signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)
signal blueprint_unlocked(blueprint_id: String)
signal trial_started
signal trial_phase_changed(phase: int)


func _ready() -> void:
	load_game()


## 기지로 이동
func go_to_base() -> void:
	current_phase = Phase.BASE
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file("res://scenes/main/base.tscn")


## 필드 레이드 시작
func start_field_raid() -> void:
	current_phase = Phase.FIELD_RAID
	raid_success = false
	player_dead = false
	trial_active = false
	kills_this_raid = 0
	InventoryManager.clear_raid_inventory()
	InventoryManager.load_from_stash()
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
	successful_raids += 1
	total_kills += kills_this_raid
	InventoryManager.transfer_to_stash()

	# 레이드 성공 XP
	add_xp(50 + kills_this_raid * 5)

	# 퀘스트 진행 체크
	_check_quest_progress()

	save_game()
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


## 기지로 돌아가기 (결과 화면에서)
func return_to_base() -> void:
	current_phase = Phase.BASE
	phase_changed.emit(current_phase)
	get_tree().change_scene_to_file("res://scenes/main/base.tscn")


## 웨이브 시작
func start_wave(wave_num: int, enemy_count: int) -> void:
	current_wave = wave_num
	enemies_remaining = enemy_count
	wave_started.emit(wave_num)


## 적 처치 시 호출
func enemy_killed(xp_value: int = 10) -> void:
	enemies_remaining -= 1
	kills_this_raid += 1
	add_xp(xp_value)
	if enemies_remaining <= 0:
		wave_completed.emit(current_wave)


#region 경험치/레벨 시스템
## 경험치 추가
func add_xp(amount: int) -> void:
	player_xp += amount
	xp_gained.emit(amount)

	while player_xp >= xp_to_next_level:
		player_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = _calculate_xp_for_level(player_level)
		_on_level_up()
		level_up.emit(player_level)


func _calculate_xp_for_level(level: int) -> int:
	return 100 + (level - 1) * 50


func _on_level_up() -> void:
	# 레벨별 제작법 해금
	match player_level:
		2:
			unlock_blueprint("smg_alpha")
		3:
			unlock_blueprint("energy_drink")
		5:
			unlock_blueprint("ar15_ranger")
		7:
			unlock_blueprint("armor_light")
#endregion


#region 제작법 해금
func unlock_blueprint(blueprint_id: String) -> void:
	if blueprint_id not in unlocked_blueprints:
		unlocked_blueprints.append(blueprint_id)
		blueprint_unlocked.emit(blueprint_id)


func has_blueprint(blueprint_id: String) -> bool:
	return blueprint_id in unlocked_blueprints
#endregion


#region 퀘스트 시스템
func accept_quest(quest_data: Dictionary) -> void:
	if quest_data["id"] in completed_quest_ids:
		return
	for q in active_quests:
		if q["id"] == quest_data["id"]:
			return
	active_quests.append(quest_data.duplicate(true))
	quest_updated.emit(quest_data["id"])


func _check_quest_progress() -> void:
	for quest in active_quests:
		match quest["type"]:
			"kill":
				quest["current"] = mini(quest["current"] + kills_this_raid, quest["target"])
			"raid_survive":
				quest["current"] = mini(quest["current"] + 1, quest["target"])
			"collect":
				# 수집 퀘스트는 아이템 획득 시 별도 처리
				pass
		quest_updated.emit(quest["id"])


func complete_quest(quest_id: String) -> void:
	var quest_index = -1
	for i in range(active_quests.size()):
		if active_quests[i]["id"] == quest_id:
			quest_index = i
			break

	if quest_index == -1:
		return

	var quest = active_quests[quest_index]

	# 보상 지급
	if quest.has("rewards"):
		var rewards = quest["rewards"]
		if rewards.has("xp"):
			add_xp(rewards["xp"])
		if rewards.has("blueprint"):
			unlock_blueprint(rewards["blueprint"])
		if rewards.has("items"):
			for item in rewards["items"]:
				InventoryManager.add_to_stash(item["id"], item["amount"])

	completed_quest_ids.append(quest_id)
	active_quests.remove_at(quest_index)
	quest_completed.emit(quest_id)
	save_game()


func is_quest_complete(quest_id: String) -> bool:
	for quest in active_quests:
		if quest["id"] == quest_id:
			return quest["current"] >= quest["target"]
	return false


func get_quest_progress(quest_id: String) -> Dictionary:
	for quest in active_quests:
		if quest["id"] == quest_id:
			return {"current": quest["current"], "target": quest["target"]}
	return {}
#endregion


#region 시련(TRIAL) 시스템
func start_trial() -> void:
	trial_active = true
	trial_started.emit()


func advance_trial_phase(phase: int) -> void:
	trial_phase_changed.emit(phase)
#endregion


#region 저장/로드
func save_game() -> void:
	var save_data = {
		"player_level": player_level,
		"player_xp": player_xp,
		"xp_to_next_level": xp_to_next_level,
		"total_kills": total_kills,
		"successful_raids": successful_raids,
		"unlocked_blueprints": unlocked_blueprints,
		"completed_quest_ids": completed_quest_ids,
		"active_quests": active_quests,
		"stash": InventoryManager.stash
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()

		if result == OK:
			var data = json.data
			player_level = data.get("player_level", 1)
			player_xp = data.get("player_xp", 0)
			xp_to_next_level = data.get("xp_to_next_level", 100)
			total_kills = data.get("total_kills", 0)
			successful_raids = data.get("successful_raids", 0)

			# typed array 로드
			unlocked_blueprints.clear()
			for bp in data.get("unlocked_blueprints", ["p1_sidearm", "bandage"]):
				unlocked_blueprints.append(bp)

			completed_quest_ids.clear()
			for qid in data.get("completed_quest_ids", []):
				completed_quest_ids.append(qid)

			# 퀘스트 로드
			active_quests.clear()
			for q in data.get("active_quests", []):
				active_quests.append(q)

			# 스태시 로드
			if data.has("stash"):
				InventoryManager.stash = data["stash"]


func reset_save() -> void:
	player_level = 1
	player_xp = 0
	xp_to_next_level = 100
	total_kills = 0
	successful_raids = 0
	unlocked_blueprints = ["p1_sidearm", "bandage"]
	completed_quest_ids.clear()
	active_quests.clear()
	InventoryManager.reset_stash()

	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
#endregion
