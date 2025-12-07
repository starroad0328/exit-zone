extends Control

## HUD 스크립트
## 체력, 스테미나, 탄약, 아이템, 추출 진행, 레벨 표시

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPLabel
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var ammo_label: Label = $AmmoLabel
@onready var bandage_label: Label = $BandageLabel
@onready var energy_label: Label = $EnergyLabel
@onready var extraction_bar: ProgressBar = $ExtractionBar
@onready var level_label: Label = $LevelLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var kills_label: Label = $KillsLabel

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

	# 게임 상태 시그널 연결
	GameState.xp_gained.connect(_on_xp_changed)
	GameState.level_up.connect(_on_level_up)

	# 초기 UI 업데이트
	_update_hp(100, 100)
	_update_stamina(100, 100)
	_update_level_display()
	_on_inventory_updated()

	if extraction_bar:
		extraction_bar.visible = false


func _connect_player_signals() -> void:
	if player:
		player.hp_changed.connect(_update_hp)
		player.stamina_changed.connect(_update_stamina)
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
	if hp_bar:
		hp_bar.max_value = maximum
		hp_bar.value = current
	if hp_label:
		hp_label.text = "HP: %d/%d" % [current, maximum]


func _update_stamina(current: float, maximum: float) -> void:
	if stamina_bar:
		stamina_bar.max_value = maximum
		stamina_bar.value = current

		# 스테미나 부족 시 색상 변경
		if current < 25:
			stamina_bar.modulate = Color(1, 0.3, 0.3)
		elif current < 50:
			stamina_bar.modulate = Color(1, 0.7, 0.3)
		else:
			stamina_bar.modulate = Color(0.3, 0.8, 1)


func _update_ammo(current: int, magazine: int) -> void:
	if ammo_label:
		ammo_label.text = "탄약: %d/%d" % [current, magazine]


func _update_level_display() -> void:
	if level_label:
		level_label.text = "Lv.%d" % GameState.player_level
	if xp_bar:
		xp_bar.max_value = GameState.xp_to_next_level
		xp_bar.value = GameState.player_xp
	if kills_label:
		kills_label.text = "Kills: %d" % GameState.kills_this_raid


func _on_inventory_updated() -> void:
	if bandage_label:
		bandage_label.text = "붕대: %d [Q]" % InventoryManager.current_bandage
	if energy_label:
		energy_label.text = "에너지: %d [E]" % InventoryManager.current_energy_drink
	if kills_label:
		kills_label.text = "Kills: %d" % GameState.kills_this_raid


func _on_extraction_started() -> void:
	if extraction_bar:
		extraction_bar.visible = true


func _on_extraction_progress(progress: float) -> void:
	if extraction_bar:
		extraction_bar.value = progress * 100
		if progress <= 0:
			extraction_bar.visible = false


func _on_xp_changed(_amount: int) -> void:
	_update_level_display()


func _on_level_up(_new_level: int) -> void:
	_update_level_display()
