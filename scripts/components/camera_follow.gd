extends Node2D

@export var target: Node2D = null
@export var speed: float = 1.0

var actual_pos = Vector2.ZERO

func _enter_tree() -> void:
    actual_pos = global_position

func _process(delta: float) -> void:
    actual_pos = actual_pos.lerp(target.global_position, delta * speed * 2.0)
    global_position = actual_pos.round()
    get_child(0).update_subpixel_position(actual_pos)
