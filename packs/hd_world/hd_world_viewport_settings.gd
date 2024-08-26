class_name HDWorldViewportSettings
extends Resource

@export var desired_res: Vector2i = Vector2i(320, 180)

@export var enable_smooth_pixelart_camera: bool = true
@export var smooth_pixelart_camera_pad: Vector2i = Vector2i(1, 1)

var _curr_pixel_offset: Vector2 = Vector2.ZERO
