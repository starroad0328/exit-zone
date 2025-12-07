extends Control

## 퀘스트 패널 UI
## 퀘스트 목록, 수락, 완료 처리

@onready var quest_list: VBoxContainer = $VBoxContainer/QuestList
@onready var active_list: VBoxContainer = $VBoxContainer/ActiveQuests

# 사용 가능한 퀘스트 정의
var available_quests: Array[Dictionary] = [
	{
		"id": "kill_scav_10",
		"name": "Scav 사냥꾼",
		"description": "Scav 10마리 처치",
		"type": "kill",
		"target": 10,
		"current": 0,
		"rewards": {"xp": 100, "items": [{"id": "ammo_9mm", "amount": 30}]}
	},
	{
		"id": "survive_3",
		"name": "생존 전문가",
		"description": "레이드 3회 생존",
		"type": "raid_survive",
		"target": 3,
		"current": 0,
		"rewards": {"xp": 150, "blueprint": "smg_alpha"}
	},
	{
		"id": "collect_scrap_20",
		"name": "재료 수집가",
		"description": "고철 20개 수집",
		"type": "collect",
		"item_id": "scrap_metal",
		"target": 20,
		"current": 0,
		"rewards": {"xp": 80, "items": [{"id": "gun_parts", "amount": 5}]}
	},
	{
		"id": "kill_scav_25",
		"name": "베테랑 사냥꾼",
		"description": "Scav 25마리 처치",
		"type": "kill",
		"target": 25,
		"current": 0,
		"rewards": {"xp": 200, "blueprint": "ar15_ranger"}
	},
	{
		"id": "survive_5",
		"name": "철인",
		"description": "레이드 5회 생존",
		"type": "raid_survive",
		"target": 5,
		"current": 0,
		"rewards": {"xp": 250, "items": [{"id": "bandage", "amount": 10}]}
	}
]


func _ready() -> void:
	GameState.quest_updated.connect(_on_quest_updated)
	GameState.quest_completed.connect(_on_quest_completed)


func refresh() -> void:
	_clear_lists()
	_populate_available_quests()
	_populate_active_quests()


func _clear_lists() -> void:
	for child in quest_list.get_children():
		child.queue_free()
	for child in active_list.get_children():
		child.queue_free()


func _populate_available_quests() -> void:
	for quest in available_quests:
		# 이미 수락했거나 완료한 퀘스트는 표시 안 함
		if quest["id"] in GameState.completed_quest_ids:
			continue
		var already_active = false
		for active in GameState.active_quests:
			if active["id"] == quest["id"]:
				already_active = true
				break
		if already_active:
			continue

		var item = _create_quest_item(quest, false)
		quest_list.add_child(item)


func _populate_active_quests() -> void:
	for quest in GameState.active_quests:
		var item = _create_quest_item(quest, true)
		active_list.add_child(item)


func _create_quest_item(quest: Dictionary, is_active: bool) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = quest["name"]
	info.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = quest["description"]
	desc_label.modulate = Color(0.7, 0.7, 0.7)
	info.add_child(desc_label)

	if is_active:
		var progress_label = Label.new()
		progress_label.text = "진행: %d/%d" % [quest["current"], quest["target"]]
		progress_label.modulate = Color(0.5, 0.8, 0.5)
		info.add_child(progress_label)

	container.add_child(info)

	var button = Button.new()
	if is_active:
		if quest["current"] >= quest["target"]:
			button.text = "완료"
			button.pressed.connect(_on_complete_quest.bind(quest["id"]))
		else:
			button.text = "진행 중"
			button.disabled = true
	else:
		button.text = "수락"
		button.pressed.connect(_on_accept_quest.bind(quest))

	container.add_child(button)
	return container


func _on_accept_quest(quest: Dictionary) -> void:
	GameState.accept_quest(quest)
	refresh()


func _on_complete_quest(quest_id: String) -> void:
	GameState.complete_quest(quest_id)
	refresh()


func _on_quest_updated(_quest_id: String) -> void:
	if visible:
		refresh()


func _on_quest_completed(_quest_id: String) -> void:
	if visible:
		refresh()
