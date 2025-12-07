extends Area2D
class_name ExtractionZone

## 추출 지점
## F키 2초 홀드로 추출

const EXTRACTION_TIME: float = 2.0

var player_in_zone: bool = false
var extraction_progress: float = 0.0
var is_extracting: bool = false

signal extraction_started
signal extraction_progress_updated(progress: float)
signal extraction_completed


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if player_in_zone and Input.is_action_pressed("interact"):
		if not is_extracting:
			is_extracting = true
			extraction_started.emit()

		extraction_progress += delta
		extraction_progress_updated.emit(extraction_progress / EXTRACTION_TIME)

		if extraction_progress >= EXTRACTION_TIME:
			_complete_extraction()
	else:
		if is_extracting:
			is_extracting = false
			extraction_progress = 0.0
			extraction_progress_updated.emit(0.0)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_zone = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_zone = false
		is_extracting = false
		extraction_progress = 0.0


func _complete_extraction() -> void:
	extraction_completed.emit()
	GameState.start_defense_raid()
