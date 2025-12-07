extends Node2D

## 필드 레이드 메인 스크립트
## 시간 제한 + 시련(TRIAL) 시스템

@onready var player: Player = $Player
@onready var extraction_zone: Node2D = $ExtractionZone
@onready var enemies: Node2D = $Enemies
@onready var loot_boxes: Node2D = $LootBoxes
@onready var hud: Control = $HUD/HUDControl
@onready var timer_label: Label = $HUD/HUDControl/TimerLabel
@onready var trial_warning: Label = $HUD/HUDControl/TrialWarning

# 시간 제한 시스템
const RAID_TIME_LIMIT: float = 180.0  # 3분
var time_remaining: float = RAID_TIME_LIMIT
var raid_started: bool = false

# 시련(TRIAL) 시스템
var trial_active: bool = false
var trial_phase: int = 0
var trial_timer: float = 0.0
const TRIAL_PHASE_DURATION: float = 10.0  # 각 페이즈 10초

# 적 스폰용
var scav_scene: PackedScene = preload("res://scenes/entities/scav.tscn")
var runner_scene: PackedScene  # 나중에 추가


func _ready() -> void:
	raid_started = true

	# 시련 시그널 연결
	GameState.trial_started.connect(_on_trial_started)

	# 타이머 라벨 초기화
	if timer_label:
		_update_timer_display()
	if trial_warning:
		trial_warning.visible = false

	# 플레이어 무기 설정
	if player:
		player.equip_weapon(InventoryManager.equipped_weapon)


func _process(delta: float) -> void:
	if not raid_started or player.is_dead:
		return

	if not trial_active:
		# 일반 시간 카운트다운
		time_remaining -= delta
		_update_timer_display()

		if time_remaining <= 0:
			_start_trial()
	else:
		# 시련 진행
		_process_trial(delta)


func _update_timer_display() -> void:
	if timer_label:
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]

		# 시간 부족 시 색상 변경
		if time_remaining <= 30:
			timer_label.modulate = Color(1, 0.3, 0.3)
		elif time_remaining <= 60:
			timer_label.modulate = Color(1, 0.7, 0.3)
		else:
			timer_label.modulate = Color(1, 1, 1)


func _start_trial() -> void:
	trial_active = true
	trial_phase = 1
	trial_timer = 0.0
	GameState.start_trial()

	if trial_warning:
		trial_warning.visible = true
		trial_warning.text = "!! TRIAL PHASE 1 !!"
		trial_warning.modulate = Color(1, 0, 0)

	if timer_label:
		timer_label.text = "TRIAL"
		timer_label.modulate = Color(1, 0, 0)

	# 첫 페이즈 적 스폰
	_spawn_trial_enemies(1)


func _process_trial(delta: float) -> void:
	trial_timer += delta

	# 페이즈 진행
	if trial_timer >= TRIAL_PHASE_DURATION:
		trial_timer = 0.0
		trial_phase += 1

		if trial_phase <= 3:
			GameState.advance_trial_phase(trial_phase)
			_spawn_trial_enemies(trial_phase)

			if trial_warning:
				trial_warning.text = "!! TRIAL PHASE %d !!" % trial_phase

	# 경고 깜빡임
	if trial_warning and trial_warning.visible:
		trial_warning.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)


func _spawn_trial_enemies(phase: int) -> void:
	var spawn_count = 0
	var enhanced_ratio = 0.0
	var include_runners = false

	match phase:
		1:
			spawn_count = 3
			enhanced_ratio = 1.0  # 전부 강화형
		2:
			spawn_count = 5
			enhanced_ratio = 0.6
			include_runners = true
		3:
			spawn_count = 8
			enhanced_ratio = 0.5
			include_runners = true

	for i in range(spawn_count):
		var spawn_pos = player.global_position + Vector2(
			randf_range(-400, 400),
			randf_range(-400, 400)
		).normalized() * randf_range(300, 500)

		var is_enhanced = randf() < enhanced_ratio

		# 러너 또는 Scav 스폰
		if include_runners and randf() < 0.3:
			_spawn_runner(spawn_pos)
		else:
			_spawn_enemy(spawn_pos, is_enhanced)


func _spawn_enemy(pos: Vector2, enhanced: bool) -> void:
	var enemy = scav_scene.instantiate() as Scav
	enemy.global_position = pos
	enemy.is_enhanced = enhanced
	enemies.add_child(enemy)


func _spawn_runner(pos: Vector2) -> void:
	# 러너는 빠르고 약한 적
	var enemy = scav_scene.instantiate() as Scav
	enemy.global_position = pos
	enemy.is_enhanced = false
	enemy.max_hp = 20.0
	enemy.move_speed = 180.0  # 매우 빠름
	enemy.attack_damage = 8.0
	enemies.add_child(enemy)

	# 러너 시각 효과
	if enemy.has_node("Sprite2D"):
		enemy.get_node("Sprite2D").modulate = Color(0.4, 0.8, 0.4)


func _on_trial_started() -> void:
	pass  # 이미 _start_trial에서 처리
