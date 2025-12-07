extends Control

## 로드아웃 패널 UI
## 레이드 출발 전 장비 선택

@onready var weapon_option: OptionButton = $VBoxContainer/WeaponOption
@onready var loadout_info: Label = $VBoxContainer/LoadoutInfo


func _ready() -> void:
	pass


func refresh() -> void:
	_populate_weapon_options()
	_update_loadout_info()


func _populate_weapon_options() -> void:
	weapon_option.clear()

	var weapons = InventoryManager.stash.get("weapons", [])
	for i in range(weapons.size()):
		var weapon_id = weapons[i]
		weapon_option.add_item(_get_weapon_name(weapon_id), i)
		weapon_option.set_item_metadata(i, weapon_id)

	# 현재 장착 무기 선택
	for i in range(weapon_option.item_count):
		if weapon_option.get_item_metadata(i) == InventoryManager.equipped_weapon:
			weapon_option.select(i)
			break


func _update_loadout_info() -> void:
	var text = "레이드 출발 시 자동 지급:\n"
	text += "- 9mm 탄약: 최대 60발\n"
	text += "- 5.56mm 탄약: 최대 60발\n"
	text += "- 붕대: 최대 3개\n"
	text += "- 에너지 드링크: 최대 2개\n\n"
	text += "현재 스태시 보유량:\n"
	text += "- 9mm: %d\n" % InventoryManager.get_stash_count("ammo_9mm")
	text += "- 5.56mm: %d\n" % InventoryManager.get_stash_count("ammo_556")
	text += "- 붕대: %d\n" % InventoryManager.get_stash_count("bandage")
	text += "- 에너지 드링크: %d" % InventoryManager.get_stash_count("energy_drink")
	loadout_info.text = text


func _get_weapon_name(weapon_id: String) -> String:
	match weapon_id:
		"p1_sidearm", "weapon_p1": return "P1 Sidearm"
		"smg_alpha", "weapon_smg": return "SMG-Alpha"
		"ar15_ranger", "weapon_ar": return "AR-15 Ranger"
		_: return weapon_id


func _on_weapon_option_item_selected(index: int) -> void:
	var weapon_id = weapon_option.get_item_metadata(index)
	InventoryManager.equipped_weapon = weapon_id
