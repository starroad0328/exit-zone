extends Node2D

## 필드 레이드 메인 스크립트

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var object_layer: TileMapLayer = $ObjectLayer
@onready var player: Player = $Player
@onready var extraction_zone: Node2D = $ExtractionZone
@onready var enemies: Node2D = $Enemies
@onready var loot_boxes: Node2D = $LootBoxes

var map_generator: FieldMapGenerator


func _ready() -> void:
	_generate_map()
	_setup_entities()


func _generate_map() -> void:
	map_generator = FieldMapGenerator.new()
	map_generator.generate_map(ground_layer, object_layer)


func _setup_entities() -> void:
	# 플레이어 위치 (스폰 구역)
	var spawn_positions := map_generator.get_spawn_positions()
	if spawn_positions.size() > 0:
		player.position = spawn_positions[0]

	# 추출 지점 위치
	var exit_pos := map_generator.get_exit_position()
	if exit_pos != Vector2.ZERO:
		extraction_zone.position = exit_pos

	# 적 위치 (핫존 근처)
	var hotzone_positions := map_generator.get_hotzone_positions()
	var enemy_nodes := enemies.get_children()
	for i in range(min(enemy_nodes.size(), hotzone_positions.size())):
		enemy_nodes[i].position = hotzone_positions[i] + Vector2(randf_range(-100, 100), randf_range(-100, 100))

	# 루트박스 위치 (핫존 및 건물 근처)
	var lootbox_nodes := loot_boxes.get_children()
	for i in range(lootbox_nodes.size()):
		if i < hotzone_positions.size():
			lootbox_nodes[i].position = hotzone_positions[i] + Vector2(randf_range(-50, 50), randf_range(-50, 50))
