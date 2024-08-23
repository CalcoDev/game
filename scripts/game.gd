extends Node


enum ProcessList {
	Game = -1,
	Default = 0,
}

func _enter_tree() -> void:
	process_priority = ProcessList.Game
