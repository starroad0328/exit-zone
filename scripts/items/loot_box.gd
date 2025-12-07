extends StaticBody2D
class_name LootBox

## 루트 상자
## 상호작용 시 아이템/재료 드롭

enum LootType { NORMAL, RARE, MATERIAL }

@export var loot_type: LootType = LootType.NORMAL
@export var loot_table: Array[Dictionary] = []
var is_looted: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	# 기본 루트 테이블 설정 (에디터에서 설정 안 했을 경우)
	if loot_table.is_empty():
		_setup_default_loot()

	# 루트 타입에 따른 시각 효과
	match loot_type:
		LootType.RARE:
			sprite.modulate = Color(1, 0.8, 0.2)  # 금색
		LootType.MATERIAL:
			sprite.modulate = Color(0.6, 0.8, 1)  # 파란색


func _setup_default_loot() -> void:
	match loot_type:
		LootType.NORMAL:
			loot_table = [
				{"item": "bandage", "amount": 1, "chance": 0.5},
				{"item": "ammo_9mm", "amount": 15, "chance": 0.4},
				{"item": "ammo_556", "amount": 10, "chance": 0.3},
				{"item": "scrap_metal", "amount": 3, "chance": 0.6},
				{"item": "cloth", "amount": 2, "chance": 0.4}
			]
		LootType.RARE:
			loot_table = [
				{"item": "bandage", "amount": 2, "chance": 0.7},
				{"item": "energy_drink", "amount": 1, "chance": 0.4},
				{"item": "ammo_9mm", "amount": 30, "chance": 0.5},
				{"item": "ammo_556", "amount": 20, "chance": 0.5},
				{"item": "gun_parts", "amount": 2, "chance": 0.6},
				{"item": "chemicals", "amount": 2, "chance": 0.5}
			]
		LootType.MATERIAL:
			loot_table = [
				{"item": "scrap_metal", "amount": 5, "chance": 0.8},
				{"item": "gun_parts", "amount": 3, "chance": 0.5},
				{"item": "cloth", "amount": 4, "chance": 0.7},
				{"item": "chemicals", "amount": 2, "chance": 0.4}
			]


func interact(_player: Player) -> void:
	if is_looted:
		return

	is_looted = true
	_give_loot()
	_update_visual()


func _give_loot() -> void:
	for loot in loot_table:
		var roll = randf()
		if roll <= loot["chance"]:
			InventoryManager.add_item(loot["item"], loot["amount"])


func _update_visual() -> void:
	# 열린 상자 표시
	sprite.modulate = Color(0.4, 0.4, 0.4, 0.5)
