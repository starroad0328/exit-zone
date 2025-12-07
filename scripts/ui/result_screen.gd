extends Control

## 결과 화면 스크립트

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var items_label: Label = $VBoxContainer/ItemsLabel


func _ready() -> void:
	if GameState.raid_success:
		status_label.text = "레이드 성공!"
		status_label.modulate = Color.GREEN
		_show_acquired_items()
	else:
		status_label.text = "레이드 실패..."
		status_label.modulate = Color.RED
		items_label.text = "모든 아이템을 잃었습니다."


func _show_acquired_items() -> void:
	var items_text = "획득 아이템:\n"
	var stash = InventoryManager.stash

	if stash["weapons"].size() > 0:
		items_text += "무기: " + ", ".join(stash["weapons"]) + "\n"
	if stash["ammo_9mm"] > 0:
		items_text += "9mm 탄약: " + str(stash["ammo_9mm"]) + "\n"
	if stash["ammo_556"] > 0:
		items_text += "5.56 탄약: " + str(stash["ammo_556"]) + "\n"
	if stash["bandage"] > 0:
		items_text += "붕대: " + str(stash["bandage"]) + "\n"

	items_label.text = items_text


func _on_continue_pressed() -> void:
	GameState.return_to_menu()
