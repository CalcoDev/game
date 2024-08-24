class_name DummyPlayer

var id: int = -1
var pos: Vector2 = Vector2(121, 58)
var my_name: String = "Sample username"
var height: float = 8.5
var age: int = 12
var is_old: bool = false

# NOTE(calco):
# Any other playe 'login' data should go here.
# For example, picture, username, terraria selected character, etc ect

# NOTE(calco): Required for Serializer.Serialize() / Serializer.Deserialize()
static func default() -> DummyPlayer:
	return DummyPlayer.new(0)

func ooga_booga() -> void:
	print("ooga booga")

func _init(p_id: int) -> void:
	id = p_id

func _to_string() -> String:
	var s: String = "{ "
	s += "id = " + str(id) + "; "
	s += "pos = " + str(pos) + "; "
	s += "my_name = " + my_name + "; "
	s += "height = " + str(height) + "; "
	s += "age = " + str(age) + "; "
	s += "is_old = " + str(is_old) + "; "
	return s + " }"
