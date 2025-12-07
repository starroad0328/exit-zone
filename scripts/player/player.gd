extends CharacterBody2D
class_name Player

## 플레이어 컨트롤러
## 이동, 조준, 사격, 회복 처리

# 스탯
const MOVE_SPEED: float = 220.0
const MAX_HP: float = 100.0

var current_hp: float = MAX_HP
var is_dead: bool = false

# 회복 쿨타임
var heal_cooldown: float = 0.0
const HEAL_COOLDOWN_TIME: float = 3.0
const HEAL_AMOUNT: float = 30.0

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
@onready var sprite: Sprite2D = $Sprite2D

# 프리로드
var projectile_scene: PackedScene = preload("res://scenes/entities/projectile.tscn")

signal hp_changed(current: float, maximum: float)
signal ammo_changed(current: int, magazine: int)
signal weapon_changed(weapon: WeaponData)
signal player_died


func _ready() -> void:
	# 기본 무기 장착
	equip_weapon("p1_sidearm")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_handle_movement()
	_handle_rotation()
	_handle_shooting(delta)
	_handle_reload(delta)
	_handle_healing(delta)
	_handle_interaction()

	move_and_slide()


func _handle_movement() -> void:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	velocity = input_dir.normalized() * MOVE_SPEED


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
	if is_dead:
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
