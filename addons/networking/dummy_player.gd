class_name DummyPlayer

var id: int = -1

# NOTE(calco):
# Any other playe 'login' data should go here.
# For example, picture, username, terraria selected character, etc ect

# NOTE(calco): Required for Serializer.Serialize() / Serializer.Deserialize()
static func default() -> DummyPlayer:
	return DummyPlayer.new(0)

func _init(p_id: int) -> void:
	id = p_id
