class_name Occluder
extends Sprite2D

# Used for lightmap calculation
@export var height: float = 0.0:
	set(value):
		height = value
		material.set_shader_parameter(&"u_height", value)

@export var hover: float = 0.0:
	set(value):
		hover = value
		material.set_shader_parameter(&"u_hover", value)
	
func _ready() -> void:
	material.set_shader_parameter(&"u_height", height / Lights.MAX_HEIGHT)
	material.set_shader_parameter(&"u_hover", hover / Lights.MAX_HEIGHT)
