extends Control

## 스태시 패널 UI
## 보유 아이템/재료 확인

@onready var weapons_list: VBoxContainer = $VBoxContainer/WeaponsList
@onready var consumables_list: VBoxContainer = $VBoxContainer/ConsumablesList
@onready var materials_list: VBoxContainer = $VBoxContainer/MaterialsList


func _ready() -> void:
	InventoryManager.stash_updated.connect(_on_stash_updated)


func refresh() -> void:
	_clear_lists()
	_populate_weapons()
	_populate_consumables()
	_populate_materials()


func _clear_lists() -> void:
	for child in weapons_list.get_children():
		child.queue_free()
	for child in consumables_list.get_children():
		child.queue_free()
	for child in materials_list.get_children():
		child.queue_free()


func _populate_weapons() -> void:
	var weapons = InventoryManager.stash.get("weapons", [])
	if weapons.is_empty():
		var label = Label.new()
		label.text = "무기 없음"
		label.modulate = Color(0.5, 0.5, 0.5)
		weapons_list.add_child(label)
		return

	for weapon_id in weapons:
		var label = Label.new()
		label.text = "- %s" % _get_weapon_name(weapon_id)
		weapons_list.add_child(label)


func _populate_consumables() -> void:
	var items = [
		{"id": "ammo_9mm", "name": "9mm 탄약"},
		{"id": "ammo_556", "name": "5.56mm 탄약"},
		{"id": "bandage", "name": "붕대"},
		{"id": "energy_drink", "name": "에너지 드링크"}
	]

	for item in items:
		var count = InventoryManager.get_stash_count(item["id"])
		var label = Label.new()
		label.text = "%s: %d" % [item["name"], count]
		if count == 0:
			label.modulate = Color(0.5, 0.5, 0.5)
		consumables_list.add_child(label)


func _populate_materials() -> void:
	var materials = [
		{"id": "scrap_metal", "name": "고철"},
		{"id": "gun_parts", "name": "총기부품"},
		{"id": "cloth", "name": "천"},
		{"id": "chemicals", "name": "화학물질"}
	]

	for mat in materials:
		var count = InventoryManager.get_stash_count(mat["id"])
		var label = Label.new()
		label.text = "%s: %d" % [mat["name"], count]
		if count == 0:
			label.modulate = Color(0.5, 0.5, 0.5)
		materials_list.add_child(label)


func _get_weapon_name(weapon_id: String) -> String:
	match weapon_id:
		"p1_sidearm", "weapon_p1": return "P1 Sidearm"
		"smg_alpha", "weapon_smg": return "SMG-Alpha"
		"ar15_ranger", "weapon_ar": return "AR-15 Ranger"
		_: return weapon_id


func _on_stash_updated() -> void:
	if visible:
		refresh()
