extends Control

## HUD 스크립트
## 체력, 탄약, 붕대, 추출 진행 표시

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPLabel
@onready var ammo_label: Label = $AmmoLabel
@onready var bandage_label: Label = $BandageLabel
@onready var extraction_bar: ProgressBar = $ExtractionBar

var player: Player


func _ready() -> void:
	# 플레이어 찾기
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		_connect_player_signals()

	# 추출존 시그널 연결
	_connect_extraction_signals()

	# 인벤토리 시그널 연결
	InventoryManager.inventory_updated.connect(_on_inventory_updated)

	# 초기 UI 업데이트
	_update_hp(100, 100)
	_on_inventory_updated()
	extraction_bar.visible = false


func _connect_player_signals() -> void:
	if player:
		player.hp_changed.connect(_update_hp)
		player.ammo_changed.connect(_update_ammo)


func _connect_extraction_signals() -> void:
	var extraction_zones = get_tree().get_nodes_in_group("extraction")
	for zone in extraction_zones:
		if zone is ExtractionZone:
			zone.extraction_started.connect(_on_extraction_started)
			zone.extraction_progress_updated.connect(_on_extraction_progress)

	# 씬에서 직접 찾기
	var zone = get_node_or_null("/root/FieldRaid/ExtractionZone")
	if zone:
		zone.extraction_started.connect(_on_extraction_started)
		zone.extraction_progress_updated.connect(_on_extraction_progress)


func _update_hp(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "HP: %d/%d" % [current, maximum]


func _update_ammo(current: int, magazine: int) -> void:
	ammo_label.text = "탄약: %d/%d" % [current, magazine]


func _on_inventory_updated() -> void:
	bandage_label.text = "붕대: %d [Q]" % InventoryManager.current_bandage


func _on_extraction_started() -> void:
	extraction_bar.visible = true


func _on_extraction_progress(progress: float) -> void:
	extraction_bar.value = progress * 100
	if progress <= 0:
		extraction_bar.visible = false
