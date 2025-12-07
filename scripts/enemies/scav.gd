extends CharacterBody2D
class_name Scav

## Scav 적 AI
## 패트롤 → 감지 → 추격 → 공격

enum State { PATROL, CHASE, ATTACK }

# 스탯
@export var max_hp: float = 30.0
@export var move_speed: float = 90.0
@export var attack_damage: float = 10.0
@export var is_enhanced: bool = false  # 강화형 여부

var current_hp: float
var current_state: State = State.PATROL
var target: Player = null

# 패트롤
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0
var patrol_wait_time: float = 0.0

# 공격
var attack_cooldown: float = 0.0
const ATTACK_INTERVAL: float = 1.0
const ATTACK_RANGE: float = 40.0

# 감지
const DETECTION_RANGE: float = 200.0
const LOSE_RANGE: float = 300.0

@onready var sprite: Sprite2D = $Sprite2D

signal died


func _ready() -> void:
	current_hp = max_hp

	# 강화형 적용
	if is_enhanced:
		max_hp = 40.0
		current_hp = max_hp
		move_speed *= 1.3
		attack_damage = 12.0
		sprite.modulate = Color(0.8, 0.2, 0.2)  # 빨간색

	# 패트롤 포인트 초기화 (현재 위치 기준)
	_setup_patrol_points()


func _physics_process(delta: float) -> void:
	attack_cooldown -= delta

	match current_state:
		State.PATROL:
			_patrol_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.ATTACK:
			_attack_state(delta)

	move_and_slide()


func _setup_patrol_points() -> void:
	var origin = global_position
	patrol_points = [
		origin + Vector2(50, 0),
		origin + Vector2(50, 50),
		origin + Vector2(0, 50),
		origin
	]


func _patrol_state(delta: float) -> void:
	# 플레이어 감지 체크
	_check_for_player()

	if patrol_wait_time > 0:
		patrol_wait_time -= delta
		velocity = Vector2.ZERO
		return

	if patrol_points.is_empty():
		return

	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - global_position).normalized()
	var distance = global_position.distance_to(target_point)

	if distance < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		patrol_wait_time = 1.0
		velocity = Vector2.ZERO
	else:
		velocity = direction * move_speed * 0.5


func _chase_state(_delta: float) -> void:
	if target == null or target.is_dead:
		current_state = State.PATROL
		return

	var distance = global_position.distance_to(target.global_position)

	# 타겟 잃음
	if distance > LOSE_RANGE:
		target = null
		current_state = State.PATROL
		return

	# 공격 범위 진입
	if distance <= ATTACK_RANGE:
		current_state = State.ATTACK
		velocity = Vector2.ZERO
		return

	# 추격
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * move_speed


func _attack_state(_delta: float) -> void:
	if target == null or target.is_dead:
		current_state = State.PATROL
		return

	var distance = global_position.distance_to(target.global_position)

	# 범위 벗어남
	if distance > ATTACK_RANGE * 1.5:
		current_state = State.CHASE
		return

	velocity = Vector2.ZERO

	# 공격
	if attack_cooldown <= 0:
		_perform_attack()
		attack_cooldown = ATTACK_INTERVAL


func _perform_attack() -> void:
	if target and not target.is_dead:
		target.take_damage(attack_damage)


func _check_for_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player is Player and not player.is_dead:
			var distance = global_position.distance_to(player.global_position)
			if distance <= DETECTION_RANGE:
				target = player
				current_state = State.CHASE
				return


func take_damage(amount: float) -> void:
	current_hp -= amount

	# 피격 효과
	sprite.modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(0.7, 0.3, 0.3) if is_enhanced else Color(0.5, 0.3, 0.3), 0.1)

	if current_hp <= 0:
		die()
	else:
		# 피격 시 플레이어 방향 추격
		if target == null:
			_check_for_player()


func die() -> void:
	GameState.enemy_killed()
	died.emit()
	queue_free()
