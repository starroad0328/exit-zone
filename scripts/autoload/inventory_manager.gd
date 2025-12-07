extends Node

## 인벤토리 관리 오토로드
## 레이드 인벤토리, 스태시, 아이템 관리

# 레이드 중 획득한 아이템 (실패 시 삭제)
var raid_inventory: Dictionary = {
	"weapons": [],
	"ammo_9mm": 0,
	"ammo_556": 0,
	"bandage": 0
}

# 안전한 창고 (레이드 성공 시 저장)
var stash: Dictionary = {
	"weapons": [],
	"ammo_9mm": 50,
	"ammo_556": 30,
	"bandage": 3
}

# 현재 장착 무기
var equipped_weapon: String = "p1_sidearm"

# 현재 탄약 (레이드 중)
var current_ammo_9mm: int = 0
var current_ammo_556: int = 0
var current_bandage: int = 0

signal inventory_updated
signal item_picked_up(item_id: String, amount: int)


func _ready() -> void:
	pass


## 레이드 시작 시 인벤토리 초기화
func clear_raid_inventory() -> void:
	raid_inventory = {
		"weapons": [],
		"ammo_9mm": 0,
		"ammo_556": 0,
		"bandage": 0
	}
	inventory_updated.emit()


## 레이드 성공 시 스태시로 이동
func transfer_to_stash() -> void:
	for weapon in raid_inventory["weapons"]:
		if weapon not in stash["weapons"]:
			stash["weapons"].append(weapon)

	stash["ammo_9mm"] += raid_inventory["ammo_9mm"]
	stash["ammo_556"] += raid_inventory["ammo_556"]
	stash["bandage"] += raid_inventory["bandage"]

	clear_raid_inventory()
	inventory_updated.emit()


## 아이템 획득
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

	stash["ammo_9mm"] -= current_ammo_9mm
	stash["ammo_556"] -= current_ammo_556
	stash["bandage"] -= current_bandage

	inventory_updated.emit()
