class_name HDWorldViewportSettings
extends Resource

@export var desired_res: Vector2i = Vector2i(320, 180)

signal on_enable_pixelart_camera_changed(bool)
@export var enable_smooth_pixelart_camera: bool = true:
    set(value):
        enable_smooth_pixelart_camera = value
        on_enable_pixelart_camera_changed.emit(value)

signal on_pixel_offset_changed(Vector2)
var _curr_pixel_offset: Vector2 = Vector2.ZERO:
    set(value):
        _curr_pixel_offset = value
        on_pixel_offset_changed.emit(value)
