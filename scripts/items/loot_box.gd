extends StaticBody2D
class_name LootBox

## 루트 상자
## 상호작용 시 아이템 드롭

@export var loot_table: Array[Dictionary] = []
var is_looted: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	# 기본 루트 테이블 설정 (에디터에서 설정 안 했을 경우)
	if loot_table.is_empty():
		_setup_default_loot()


func _setup_default_loot() -> void:
	loot_table = [
		{"item": "bandage", "amount": 1, "chance": 0.5},
		{"item": "ammo_9mm", "amount": 15, "chance": 0.3},
		{"item": "ammo_556", "amount": 10, "chance": 0.2}
	]


func interact(player: Player) -> void:
	if is_looted:
		return

	is_looted = true
	_give_loot(player)
	_update_visual()


func _give_loot(_player: Player) -> void:
	for loot in loot_table:
		var roll = randf()
		if roll <= loot["chance"]:
			InventoryManager.add_item(loot["item"], loot["amount"])


func _update_visual() -> void:
	# 열린 상자 표시
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.7)
