extends Control

## 메인 메뉴 스크립트


func _on_start_pressed() -> void:
	InventoryManager.load_from_stash()
	GameState.start_field_raid()


func _on_quit_pressed() -> void:
	get_tree().quit()
