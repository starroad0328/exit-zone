extends Node2D

## 디펜스 레이드 씬 관리
## 웨이브 스포너, 승리/패배 조건

const WAVE_1_COUNT: int = 4
const WAVE_2_COUNT: int = 6
const REST_TIME: float = 5.0

var current_wave: int = 0
var enemies_alive: int = 0
var is_resting: bool = false

var scav_scene: PackedScene = preload("res://scenes/entities/scav.tscn")

@onready var spawn_points: Array[Marker2D] = []
@onready var wave_label: Label = $HUD/HUDControl/WaveLabel
@onready var player: Player = $Player


func _ready() -> void:
	# 스폰 포인트 수집
	for child in $SpawnPoints.get_children():
		if child is Marker2D:
			spawn_points.append(child)

	# 웨이브 완료 시그널 연결
	GameState.wave_completed.connect(_on_wave_completed)

	# 첫 웨이브 시작
	await get_tree().create_timer(1.0).timeout
	_start_wave(1)


func _start_wave(wave_num: int) -> void:
	current_wave = wave_num
	is_resting = false

	var enemy_count = WAVE_1_COUNT if wave_num == 1 else WAVE_2_COUNT
	var is_enhanced = wave_num == 2

	wave_label.text = "Wave %d" % wave_num

	GameState.start_wave(wave_num, enemy_count)
	enemies_alive = enemy_count

	# 적 스폰
	for i in range(enemy_count):
		var spawn_point = spawn_points[i % spawn_points.size()]
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		_spawn_enemy(spawn_point.global_position + offset, is_enhanced)


func _spawn_enemy(pos: Vector2, enhanced: bool) -> void:
	var enemy = scav_scene.instantiate() as Scav
	enemy.global_position = pos
	enemy.is_enhanced = enhanced
	enemy.died.connect(_on_enemy_died)
	$Enemies.add_child(enemy)


func _on_enemy_died() -> void:
	enemies_alive -= 1


func _on_wave_completed(wave_num: int) -> void:
	if wave_num == 1:
		# 휴식 후 2웨이브
		wave_label.text = "휴식 중..."
		is_resting = true
		await get_tree().create_timer(REST_TIME).timeout
		_start_wave(2)
	elif wave_num == 2:
		# 레이드 성공
		wave_label.text = "승리!"
		await get_tree().create_timer(2.0).timeout
		GameState.complete_raid()
