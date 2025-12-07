extends CharacterBody2D
class_name Player

## 플레이어 컨트롤러
## 이동, 조준, 사격, 회복, 스테미나, 회피 처리

# 스탯
const MOVE_SPEED: float = 220.0
const SPRINT_SPEED: float = 330.0
const MAX_HP: float = 100.0
const MAX_STAMINA: float = 100.0

var current_hp: float = MAX_HP
var current_stamina: float = MAX_STAMINA
var is_dead: bool = false

# 스테미나 관련
const STAMINA_SPRINT_COST: float = 12.0  # 초당 소모
const STAMINA_DODGE_COST: float = 25.0
const STAMINA_REGEN: float = 5.0  # 초당 회복
var is_sprinting: bool = false

# 회피 관련
const DODGE_SPEED: float = 500.0
const DODGE_DURATION: float = 0.2
const DODGE_INVINCIBLE_TIME: float = 0.15
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_direction: Vector2 = Vector2.ZERO
var is_invincible: bool = false

# 회복 쿨타임
var heal_cooldown: float = 0.0
const HEAL_COOLDOWN_TIME: float = 3.0
const HEAL_AMOUNT: float = 30.0

# 에너지 드링크
const STAMINA_RESTORE: float = 40.0

# 무기 관련
var current_weapon: WeaponData
var current_ammo: int = 0
var is_reloading: bool = false
var fire_cooldown: float = 0.0
var reload_timer: float = 0.0

# 상호작용
var interactable_object: Node2D = null

# 노드 참조
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var muzzle: Marker2D = $WeaponPivot/Muzzle
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# 프리로드
var projectile_scene: PackedScene = preload("res://scenes/entities/projectile.tscn")

signal hp_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal ammo_changed(current: int, magazine: int)
signal weapon_changed(weapon: WeaponData)
signal player_died


func _ready() -> void:
	# 기본 무기 장착
	equip_weapon("p1_sidearm")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if is_dodging:
		_handle_dodge(delta)
	else:
		_handle_movement(delta)
		_handle_dodge_input()

	_handle_rotation()
	_handle_shooting(delta)
	_handle_reload(delta)
	_handle_healing(delta)
	_handle_stamina_items()
	_handle_interaction()
	_handle_stamina_regen(delta)

	move_and_slide()


func _handle_movement(delta: float) -> void:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	# 스프린트 체크
	is_sprinting = Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO and current_stamina > 0

	var speed = MOVE_SPEED
	if is_sprinting:
		speed = SPRINT_SPEED
		current_stamina -= STAMINA_SPRINT_COST * delta
		current_stamina = maxf(current_stamina, 0)
		stamina_changed.emit(current_stamina, MAX_STAMINA)

	velocity = input_dir.normalized() * speed

	# 애니메이션 처리
	if velocity.length() > 0:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")


func _handle_rotation() -> void:
	var mouse_pos = get_global_mouse_position()
	weapon_pivot.look_at(mouse_pos)


func _handle_shooting(delta: float) -> void:
	fire_cooldown -= delta

	if Input.is_action_pressed("shoot") and fire_cooldown <= 0 and not is_reloading:
		if current_ammo > 0:
			_fire()
		elif current_ammo == 0:
			start_reload()


func _fire() -> void:
	if current_weapon == null:
		return

	current_ammo -= 1
	fire_cooldown = current_weapon.get_fire_interval()

	# 탄환 생성
	var projectile = projectile_scene.instantiate()
	projectile.global_position = muzzle.global_position

	# 탄퍼짐 적용
	var spread_angle = randf_range(-current_weapon.spread, current_weapon.spread)
	projectile.rotation = weapon_pivot.rotation + spread_angle

	projectile.setup(current_weapon.damage, current_weapon.projectile_speed, true)
	get_tree().current_scene.add_child(projectile)

	ammo_changed.emit(current_ammo, current_weapon.magazine_size)


func _handle_reload(delta: float) -> void:
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			_finish_reload()

	if Input.is_action_just_pressed("reload") and not is_reloading:
		start_reload()


func start_reload() -> void:
	if current_weapon == null or is_reloading:
		return
	if current_ammo >= current_weapon.magazine_size:
		return

	is_reloading = true
	reload_timer = current_weapon.reload_time


func _finish_reload() -> void:
	is_reloading = false
	current_ammo = current_weapon.magazine_size
	ammo_changed.emit(current_ammo, current_weapon.magazine_size)


func _handle_healing(delta: float) -> void:
	heal_cooldown -= delta

	if Input.is_action_just_pressed("heal") and heal_cooldown <= 0:
		if current_hp < MAX_HP and InventoryManager.use_bandage():
			current_hp = minf(current_hp + HEAL_AMOUNT, MAX_HP)
			heal_cooldown = HEAL_COOLDOWN_TIME
			hp_changed.emit(current_hp, MAX_HP)


func _handle_stamina_items() -> void:
	# E키로 에너지 드링크 사용
	if Input.is_action_just_pressed("use_energy"):
		if current_stamina < MAX_STAMINA and InventoryManager.use_energy_drink():
			current_stamina = minf(current_stamina + STAMINA_RESTORE, MAX_STAMINA)
			stamina_changed.emit(current_stamina, MAX_STAMINA)


func _handle_dodge_input() -> void:
	if Input.is_action_just_pressed("dodge") and current_stamina >= STAMINA_DODGE_COST:
		var input_dir = Vector2.ZERO
		input_dir.x = Input.get_axis("move_left", "move_right")
		input_dir.y = Input.get_axis("move_up", "move_down")

		if input_dir == Vector2.ZERO:
			# 입력 없으면 마우스 반대 방향으로 회피
			var mouse_dir = (get_global_mouse_position() - global_position).normalized()
			dodge_direction = -mouse_dir
		else:
			dodge_direction = input_dir.normalized()

		is_dodging = true
		is_invincible = true
		dodge_timer = DODGE_DURATION
		current_stamina -= STAMINA_DODGE_COST
		stamina_changed.emit(current_stamina, MAX_STAMINA)

		# 무적 타이머
		get_tree().create_timer(DODGE_INVINCIBLE_TIME).timeout.connect(_end_invincibility)


func _handle_dodge(delta: float) -> void:
	velocity = dodge_direction * DODGE_SPEED
	dodge_timer -= delta

	if dodge_timer <= 0:
		is_dodging = false


func _end_invincibility() -> void:
	is_invincible = false


func _handle_stamina_regen(delta: float) -> void:
	if not is_sprinting and not is_dodging and current_stamina < MAX_STAMINA:
		current_stamina += STAMINA_REGEN * delta
		current_stamina = minf(current_stamina, MAX_STAMINA)
		stamina_changed.emit(current_stamina, MAX_STAMINA)


func _handle_interaction() -> void:
	if Input.is_action_just_pressed("interact") and interactable_object != null:
		if interactable_object.has_method("interact"):
			interactable_object.interact(self)


## 무기 장착
func equip_weapon(weapon_id: String) -> void:
	var weapon_path = "res://resources/weapons/" + weapon_id + ".tres"
	current_weapon = load(weapon_path) as WeaponData

	if current_weapon:
		current_ammo = current_weapon.magazine_size
		ammo_changed.emit(current_ammo, current_weapon.magazine_size)
		weapon_changed.emit(current_weapon)


## 피격 처리
func take_damage(amount: float) -> void:
	if is_dead or is_invincible:
		return

	current_hp -= amount
	hp_changed.emit(current_hp, MAX_HP)

	if current_hp <= 0:
		die()


## 사망 처리
func die() -> void:
	is_dead = true
	player_died.emit()
	GameState.fail_raid()


## 상호작용 가능 오브젝트 설정
func set_interactable(obj: Node2D) -> void:
	interactable_object = obj


func clear_interactable(obj: Node2D) -> void:
	if interactable_object == obj:
		interactable_object = null


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("interact"):
		set_interactable(area.get_parent())


func _on_interaction_area_exited(area: Area2D) -> void:
	if area.get_parent().has_method("interact"):
		clear_interactable(area.get_parent())
