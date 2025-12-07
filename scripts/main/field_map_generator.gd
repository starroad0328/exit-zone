extends Node
class_name FieldMapGenerator

## 필드 레이드 맵 생성기
## ASCII 맵 데이터를 기반으로 타일맵 생성

const MAP_DATA: Array[String] = [
	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"~~~~~~~FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF~~~~~~~~~~~~~",
	"~~~~~~FF..................RRRR..............FF~~~~~~~~~~~",
	"~~~~~FF....HHHHH..........R  R.....TTTTT.....FF~~~~~~~~~~",
	"~~~~FF....H   H..........RRRR.....T   T.......FF~~~~~~~~~",
	"~~~~FF....HHH H...................TTTTT.......FF~~~~~~~~~",
	"~~~~F..........................................F~~~~~~~~~",
	"~~~~F.....MMMMMMM....+++++....MMMMMMM.........F~~~~~~~~~~",
	"~~~FF.....M     M...+     +...M     M........FF~~~~~~~~~~",
	"~~FF......M     M..+  X  X +..M     M.........FF~~~~~~~~~",
	"~FF.......MMMMMMM...+  X  X +..MMMMMMM.........FF~~~~~~~~",
	"~F...................+     +....................F~~~~~~~~~",
	"~F.......CCCCC........+++++.........SSSS........F~~~~~~~~~",
	"~F.......C   C.......................S  S.......F~~~~~~~~~",
	"~F.......CCCCC.......................SSSS.......F~~~~~~~~~",
	"~FF..................GGGGGG....................FF~~~~~~~~~",
	"~~~FF................G    G..................FF~~~~~~~~~~",
	"~~~~F................G EXITG..................F~~~~~~~~~~",
	"~~~~FF...............G    G.................FF~~~~~~~~~~~",
	"~~~~~FFFFFFFFFFFFFFFFGGGGGGFFFFFFFFFFFFFFFFFFF~~~~~~~~~~~~",
	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
]

# 타일 좌표 매핑 (desert_tileset 기준)
const GROUND_TILES := {
	"~": Vector2i(6, 1),   # 수풀/경계
	"F": Vector2i(5, 5),   # 풀밭
	".": Vector2i(10, 3),  # 모래 바닥
	"+": Vector2i(8, 5),   # 도로
	" ": Vector2i(11, 3),  # 실내 바닥
}

const OBJECT_TILES := {
	"R": Vector2i(4, 1),   # 바위
	"T": Vector2i(7, 1),   # 나무
	"H": Vector2i(0, 3),   # 주택 벽
	"M": Vector2i(1, 3),   # 창고 벽
	"C": Vector2i(2, 3),   # 오두막 벽
	"G": Vector2i(0, 7),   # 게이트
	"X": Vector2i(4, 2),   # 핫존 표시 (작은 바위)
	"S": Vector2i(5, 2),   # 스폰 표시
}

var ground_layer: TileMapLayer
var object_layer: TileMapLayer


func generate_map(p_ground_layer: TileMapLayer, p_object_layer: TileMapLayer) -> void:
	ground_layer = p_ground_layer
	object_layer = p_object_layer

	# 기존 타일 클리어
	ground_layer.clear()
	object_layer.clear()

	# 맵 생성
	for y in range(MAP_DATA.size()):
		var row: String = MAP_DATA[y]
		for x in range(row.length()):
			var char: String = row[x]
			_place_tile(x, y, char)


func _place_tile(x: int, y: int, char: String) -> void:
	var pos := Vector2i(x - MAP_DATA[0].length() / 2, y - MAP_DATA.size() / 2)

	# 바닥 타일 배치
	if char in GROUND_TILES:
		ground_layer.set_cell(pos, 0, GROUND_TILES[char])
	elif char in OBJECT_TILES:
		# 오브젝트 아래에는 기본 바닥
		ground_layer.set_cell(pos, 0, GROUND_TILES["."])
		object_layer.set_cell(pos, 0, OBJECT_TILES[char])
	elif char == " ":
		# 건물 내부 빈 공간
		ground_layer.set_cell(pos, 0, GROUND_TILES[" "])


func get_spawn_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for y in range(MAP_DATA.size()):
		var row: String = MAP_DATA[y]
		for x in range(row.length()):
			if row[x] == "S":
				var pos := Vector2(
					(x - MAP_DATA[0].length() / 2) * 16 * 4,
					(y - MAP_DATA.size() / 2) * 16 * 4
				)
				positions.append(pos)
	return positions


func get_hotzone_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for y in range(MAP_DATA.size()):
		var row: String = MAP_DATA[y]
		for x in range(row.length()):
			if row[x] == "X":
				var pos := Vector2(
					(x - MAP_DATA[0].length() / 2) * 16 * 4,
					(y - MAP_DATA.size() / 2) * 16 * 4
				)
				positions.append(pos)
	return positions


func get_exit_position() -> Vector2:
	for y in range(MAP_DATA.size()):
		var row: String = MAP_DATA[y]
		var exit_idx := row.find("EXIT")
		if exit_idx != -1:
			return Vector2(
				(exit_idx - MAP_DATA[0].length() / 2 + 2) * 16 * 4,
				(y - MAP_DATA.size() / 2) * 16 * 4
			)
	return Vector2.ZERO
