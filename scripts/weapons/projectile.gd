extends Area2D
class_name Projectile

## 탄환 스크립트
## 이동, 충돌, 데미지 처리

var damage: int = 10
var speed: float = 800.0
var is_player_bullet: bool = true
var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	# 타이머로 수명 관리
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)


func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta


func setup(dmg: int, spd: float, from_player: bool) -> void:
	damage = dmg
	speed = spd
	is_player_bullet = from_player

	# 충돌 레이어 설정
	collision_layer = 4  # projectile 레이어
	if is_player_bullet:
		collision_mask = 2  # enemy 레이어
	else:
		collision_mask = 1  # player 레이어


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	# 벽 등 충돌
	queue_free()


func _on_lifetime_expired() -> void:
	queue_free()
