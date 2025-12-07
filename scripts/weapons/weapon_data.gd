extends Resource
class_name WeaponData

## 무기 데이터 리소스
## 각 무기의 스탯을 정의

@export var weapon_id: String = ""
@export var weapon_name: String = ""
@export var damage: int = 10
@export var fire_rate: float = 3.0  # 초당 발사 횟수
@export var magazine_size: int = 12
@export var reload_time: float = 1.2
@export var ammo_type: String = "9mm"  # "9mm" 또는 "556"
@export var projectile_speed: float = 800.0
@export var spread: float = 0.0  # 탄퍼짐 (라디안)


## 발사 간격 계산
func get_fire_interval() -> float:
	return 1.0 / fire_rate
