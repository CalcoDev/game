extends Node

@export var _ready_btn: Button = null

func _ready() -> void:
	_ready_btn.pressed.connect(_handle_ready_pressed)

func _handle_ready_pressed() -> void:
	Game.change_scene_file("res://scenes/world.tscn", Game.TRANSITION_FADE)
