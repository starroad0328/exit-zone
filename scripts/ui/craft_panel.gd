extends Control

## 제작 패널 UI
## 아이템 제작 (블루프린트 + 재료 → 결과물)

@onready var recipe_list: VBoxContainer = $VBoxContainer/RecipeList
@onready var materials_label: Label = $VBoxContainer/MaterialsLabel

# 제작 레시피 정의
var recipes: Array[Dictionary] = [
	{
		"id": "bandage",
		"name": "붕대",
		"requirements": {"cloth": 2},
		"result_amount": 2,
		"blueprint_required": "bandage"
	},
	{
		"id": "energy_drink",
		"name": "에너지 드링크",
		"requirements": {"chemicals": 2},
		"result_amount": 1,
		"blueprint_required": "energy_drink"
	},
	{
		"id": "ammo_9mm",
		"name": "9mm 탄약",
		"requirements": {"scrap_metal": 2, "chemicals": 1},
		"result_amount": 15,
		"blueprint_required": "p1_sidearm"
	},
	{
		"id": "ammo_556",
		"name": "5.56mm 탄약",
		"requirements": {"scrap_metal": 3, "chemicals": 2},
		"result_amount": 10,
		"blueprint_required": "ar15_ranger"
	},
	{
		"id": "weapon_smg",
		"name": "SMG-Alpha",
		"requirements": {"scrap_metal": 10, "gun_parts": 5},
		"result_amount": 1,
		"blueprint_required": "smg_alpha"
	},
	{
		"id": "weapon_ar",
		"name": "AR-15 Ranger",
		"requirements": {"scrap_metal": 15, "gun_parts": 8, "chemicals": 3},
		"result_amount": 1,
		"blueprint_required": "ar15_ranger"
	}
]


func _ready() -> void:
	InventoryManager.stash_updated.connect(_on_stash_updated)


func refresh() -> void:
	_clear_list()
	_update_materials_display()
	_populate_recipes()


func _clear_list() -> void:
	for child in recipe_list.get_children():
		child.queue_free()


func _update_materials_display() -> void:
	var text = "보유 재료: "
	text += "고철 %d | " % InventoryManager.get_stash_count("scrap_metal")
	text += "총기부품 %d | " % InventoryManager.get_stash_count("gun_parts")
	text += "천 %d | " % InventoryManager.get_stash_count("cloth")
	text += "화학물질 %d" % InventoryManager.get_stash_count("chemicals")
	materials_label.text = text


func _populate_recipes() -> void:
	for recipe in recipes:
		# 블루프린트 해금 확인
		if not GameState.has_blueprint(recipe["blueprint_required"]):
			continue

		var item = _create_recipe_item(recipe)
		recipe_list.add_child(item)


func _create_recipe_item(recipe: Dictionary) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = "%s (x%d)" % [recipe["name"], recipe["result_amount"]]
	info.add_child(name_label)

	var req_label = Label.new()
	var req_text = "필요: "
	var requirements = recipe["requirements"]
	var req_parts = []
	for mat_id in requirements:
		var mat_name = _get_material_name(mat_id)
		var have = InventoryManager.get_stash_count(mat_id)
		var need = requirements[mat_id]
		var color = "green" if have >= need else "red"
		req_parts.append("[color=%s]%s %d/%d[/color]" % [color, mat_name, have, need])
	req_text += ", ".join(req_parts)
	req_label.text = req_text
	req_label.modulate = Color(0.7, 0.7, 0.7)
	info.add_child(req_label)

	container.add_child(info)

	var button = Button.new()
	var can_craft = InventoryManager.has_materials(requirements)
	button.text = "제작"
	button.disabled = not can_craft
	button.pressed.connect(_on_craft_pressed.bind(recipe))

	container.add_child(button)
	return container


func _get_material_name(mat_id: String) -> String:
	match mat_id:
		"scrap_metal": return "고철"
		"gun_parts": return "총기부품"
		"cloth": return "천"
		"chemicals": return "화학물질"
		_: return mat_id


func _on_craft_pressed(recipe: Dictionary) -> void:
	var success = InventoryManager.craft_item(
		recipe["requirements"],
		recipe["id"],
		recipe["result_amount"]
	)
	if success:
		refresh()


func _on_stash_updated() -> void:
	if visible:
		refresh()
