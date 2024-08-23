@tool
class_name HDWorldCamera
extends Camera2D

@export_group("Settings")
@export var settings: HDWorldViewportSettings = null

var _old_pos: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
    editor_draw_screen = false

func _process(_dt: float) -> void:
    if global_position != _old_pos:
        _handle_position_change()
        _old_pos = global_position

func _draw() -> void:
    _draw_viewport_rect()

func _draw_viewport_rect() -> void:
    if settings != null:
        var half_size: Vector2 = Vector2(settings.desired_res / 2)
        var r: Rect2 = Rect2(-half_size - Vector2(0.5, 0.5), Vector2(settings.desired_res) + Vector2.ONE)
        draw_rect(r, Color.RED, false, 1.0, false)
        # draw_line(-half_size - Vector2.RIGHT * 0.5, -half_size + Vector2.DOWN * settings.desired_res.y, Color.RED, 1.0, false)

func _handle_position_change() -> void:
    queue_redraw()
