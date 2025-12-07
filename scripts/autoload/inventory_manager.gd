extends Node

## 인벤토리 관리 오토로드
## 레이드 인벤토리, 스태시, 아이템/재료 관리

# 레이드 중 획득한 아이템 (실패 시 삭제)
var raid_inventory: Dictionary = {
	"weapons": [],
	"ammo_9mm": 0,
	"ammo_556": 0,
	"bandage": 0,
	"energy_drink": 0,
	# 재료
	"scrap_metal": 0,
	"gun_parts": 0,
	"cloth": 0,
	"chemicals": 0
}

# 안전한 창고 (레이드 성공 시 저장)
var stash: Dictionary = {
	"weapons": ["p1_sidearm"],
	"ammo_9mm": 60,
	"ammo_556": 30,
	"bandage": 5,
	"energy_drink": 2,
	# 재료
	"scrap_metal": 10,
	"gun_parts": 5,
	"cloth": 8,
	"chemicals": 3
}

# 현재 장착 무기
var equipped_weapon: String = "p1_sidearm"

# 현재 소지품 (레이드 중)
var current_ammo_9mm: int = 0
var current_ammo_556: int = 0
var current_bandage: int = 0
var current_energy_drink: int = 0

signal inventory_updated
signal item_picked_up(item_id: String, amount: int)
signal stash_updated


func _ready() -> void:
	pass


## 레이드 시작 시 인벤토리 초기화
func clear_raid_inventory() -> void:
	raid_inventory = {
		"weapons": [],
		"ammo_9mm": 0,
		"ammo_556": 0,
		"bandage": 0,
		"energy_drink": 0,
		"scrap_metal": 0,
		"gun_parts": 0,
		"cloth": 0,
		"chemicals": 0
	}
	current_ammo_9mm = 0
	current_ammo_556 = 0
	current_bandage = 0
	current_energy_drink = 0
	inventory_updated.emit()


## 레이드 성공 시 스태시로 이동
func transfer_to_stash() -> void:
	for weapon in raid_inventory["weapons"]:
		if weapon not in stash["weapons"]:
			stash["weapons"].append(weapon)

	stash["ammo_9mm"] += raid_inventory["ammo_9mm"]
	stash["ammo_556"] += raid_inventory["ammo_556"]
	stash["bandage"] += raid_inventory["bandage"]
	stash["energy_drink"] += raid_inventory["energy_drink"]
	stash["scrap_metal"] += raid_inventory["scrap_metal"]
	stash["gun_parts"] += raid_inventory["gun_parts"]
	stash["cloth"] += raid_inventory["cloth"]
	stash["chemicals"] += raid_inventory["chemicals"]

	clear_raid_inventory()
	stash_updated.emit()
	inventory_updated.emit()


## 아이템 획득 (레이드 중)
func add_item(item_id: String, amount: int = 1) -> void:
	match item_id:
		"weapon_p1", "weapon_smg", "weapon_ar":
			if item_id not in raid_inventory["weapons"]:
				raid_inventory["weapons"].append(item_id)
		"ammo_9mm":
			raid_inventory["ammo_9mm"] += amount
			current_ammo_9mm += amount
		"ammo_556":
			raid_inventory["ammo_556"] += amount
			current_ammo_556 += amount
		"bandage":
			raid_inventory["bandage"] += amount
			current_bandage += amount
		"energy_drink":
			raid_inventory["energy_drink"] += amount
			current_energy_drink += amount
		"scrap_metal", "gun_parts", "cloth", "chemicals":
			raid_inventory[item_id] += amount

	item_picked_up.emit(item_id, amount)
	inventory_updated.emit()


## 붕대 사용
func use_bandage() -> bool:
	if current_bandage > 0:
		current_bandage -= 1
		raid_inventory["bandage"] -= 1
		inventory_updated.emit()
		return true
	return false


## 탄약 소모
func consume_ammo(ammo_type: String, amount: int = 1) -> bool:
	match ammo_type:
		"9mm":
			if current_ammo_9mm >= amount:
				current_ammo_9mm -= amount
				return true
		"556":
			if current_ammo_556 >= amount:
				current_ammo_556 -= amount
				return true
	return false


## 탄약 확인
func get_ammo_count(ammo_type: String) -> int:
	match ammo_type:
		"9mm":
			return current_ammo_9mm
		"556":
			return current_ammo_556
	return 0


## 레이드 시작 전 스태시에서 로드
func load_from_stash() -> void:
	current_ammo_9mm = mini(stash["ammo_9mm"], 60)
	current_ammo_556 = mini(stash["ammo_556"], 60)
	current_bandage = mini(stash["bandage"], 3)
	current_energy_drink = mini(stash["energy_drink"], 2)

	stash["ammo_9mm"] -= current_ammo_9mm
	stash["ammo_556"] -= current_ammo_556
	stash["bandage"] -= current_bandage
	stash["energy_drink"] -= current_energy_drink

	inventory_updated.emit()


## 스태시에 직접 추가 (퀘스트 보상 등)
func add_to_stash(item_id: String, amount: int = 1) -> void:
	if item_id.begins_with("weapon_"):
		if item_id not in stash["weapons"]:
			stash["weapons"].append(item_id)
	elif stash.has(item_id):
		stash[item_id] += amount
	stash_updated.emit()


## 스태시에서 아이템 사용/제거
func remove_from_stash(item_id: String, amount: int = 1) -> bool:
	if item_id.begins_with("weapon_"):
		if item_id in stash["weapons"]:
			stash["weapons"].erase(item_id)
			stash_updated.emit()
			return true
	elif stash.has(item_id) and stash[item_id] >= amount:
		stash[item_id] -= amount
		stash_updated.emit()
		return true
	return false


## 스태시 아이템 개수 확인
func get_stash_count(item_id: String) -> int:
	if item_id.begins_with("weapon_"):
		return 1 if item_id in stash["weapons"] else 0
	return stash.get(item_id, 0)


## 에너지 드링크 사용
func use_energy_drink() -> bool:
	if current_energy_drink > 0:
		current_energy_drink -= 1
		raid_inventory["energy_drink"] -= 1
		inventory_updated.emit()
		return true
	return false


## 스태시 초기화 (새 게임)
func reset_stash() -> void:
	stash = {
		"weapons": ["p1_sidearm"],
		"ammo_9mm": 60,
		"ammo_556": 30,
		"bandage": 5,
		"energy_drink": 2,
		"scrap_metal": 10,
		"gun_parts": 5,
		"cloth": 8,
		"chemicals": 3
	}
	stash_updated.emit()


## 크래프팅: 재료 확인
func has_materials(requirements: Dictionary) -> bool:
	for item_id in requirements:
		if get_stash_count(item_id) < requirements[item_id]:
			return false
	return true


## 크래프팅: 재료 소모 및 결과물 추가
func craft_item(requirements: Dictionary, result_id: String, result_amount: int = 1) -> bool:
	if not has_materials(requirements):
		return false

	for item_id in requirements:
		remove_from_stash(item_id, requirements[item_id])

	add_to_stash(result_id, result_amount)
	return true
