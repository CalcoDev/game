@tool
class_name HDWorldCamera
extends Camera2D

@export_group("Settings")
@export var settings: HDWorldViewportSettings = null
@export var draw_debug: bool = true:
    set(value):
        draw_debug = value
        queue_redraw()

@export var autoupdate_subpixel_position: bool = true

var _old_pos: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
    if Engine.is_editor_hint():
        editor_draw_screen = false

func _process(_dt: float) -> void:
    if Engine.is_editor_hint():
        if global_position != _old_pos:
            _handle_position_change()
            _old_pos = global_position
    elif autoupdate_subpixel_position:
        update_subpixel_position(global_position)

func _draw() -> void:
    if Engine.is_editor_hint():
        _draw_viewport_rect()

func update_subpixel_position(pos: Vector2) -> void:
    settings._curr_pixel_offset = round(pos) - pos

func _draw_viewport_rect() -> void:
    if settings != null and draw_debug:
        var half_size: Vector2 = Vector2(settings.desired_res / 2)
        var r: Rect2 = Rect2(-half_size - Vector2(0.5, 0.5), Vector2(settings.desired_res) + Vector2.ONE)
        draw_rect(r, Color.RED, false, 1.0, false)
        
        # if settings.enable_smooth_pixelart_camera:
        #     var v2 = Vector2(settings.smooth_pixelart_camera_pad)
        #     r.position -= v2
        #     r.size += v2 * 2.0
        #     draw_rect(r, Color.AQUA, false, 1.0, false)

func _handle_position_change() -> void:
    queue_redraw()
