class_name Lights
extends Node

# const EMITTER_GROUP: StringName = &"lights_emitter"
const OCCLUDER_GROUP: StringName = &"lights_occluder"

const MAX_HEIGHT: float = 500.0

@export var occluder_material: ShaderMaterial = null

@export var sky_modulate: CanvasModulate = null
@export var sky_colors: Gradient

# Set => outputs to custom thing. By default should be used as a get.
@export var output_texture: TextureRect = null

@export var time_scale: float = 1.0
@export var min_shadow_length: float = 10
@export var max_shadow_length: float = 40
var sun_angle: float = PI

var scene_viewport: SubViewport
var scene_camera: Camera2D
@export var actual_scene_camera: Node2D = null

var sync_refs: Array[ObjSync] = []
class ObjSync extends Node2D:
	var original: Node2D = null
	var copy: Node2D = null
	func _init(og: Node2D, cp: Node2D) -> void:
		original = og
		copy = cp
	func update() -> void:
		copy.global_position = original.global_position
		copy.global_rotation = original.global_rotation
		copy.global_scale = original.global_scale
		# TODO(calco): Maybe sync differently somehow

func _enter_tree() -> void:
	process_priority = Game.ProcessList.Lights
	scene_viewport = $"SceneViewport"
	scene_camera = $"SceneViewport/Camera2D"

	_setup_render_passes()
	call_deferred("_setup_scene")

	Game.on_post_process.connect(_post_process)

var time_of_day: float = 0.0
var sanglesign = 1.0
func _process(delta: float) -> void:
	time_of_day += time_scale * delta * 0.05
	if time_of_day > 2.0:
		time_of_day = 0.0
	
	var t0 = (time_of_day - 0.15) / 2.0
	t0 = t0 - floor(t0)
	sky_modulate.color = sky_colors.sample(t0)
	
	var t = time_of_day
	if t > 1.0:
		t = 2.0 - time_of_day
	sun_angle = t * PI
	var shadow_dir = Vector2(sin(sun_angle), cos(sun_angle)).normalized()
	if time_of_day > 1.0:
		shadow_dir.x *= -1.0
	var elevation = 1.0 - max(sin(sun_angle), 0.0)
	# var shadow_length = lerp(min_shadow_length, max_shadow_length, elevation)
	
	$"RenderPasses/ShadowPixelsPass/TextureRect".material.set_shader_parameter(&"u_light_dir", Vector3(-1, 1, elevation * 20.0 / MAX_HEIGHT))
	# print()
	# NOTE(calco): Maybe updating after makes better order or sth
	# $"RenderPasses/ShadowPixelsPass/TextureRect".material.set_shader_parameter(&"u_light_dir", Vector3(shadow_dir.x, shadow_dir.y, 1 / MAX_HEIGHT))
	# $"RenderPasses/ShadowPixelsPass/TextureRect".material.set_shader_parameter(&"u_max_height", 500.0)
	# $"RenderPasses/ShadowPixelsPass/TextureRect".material.set_shader_parameter(&"u_distance", shadow_length)

func _post_process(_delta: float) -> void:
	scene_camera.global_position = actual_scene_camera.global_position
	for sync in sync_refs:
		sync.update()

func _setup_render_passes() -> void:
	# TODO(calco): Slightly scuffed because now that may or may not be offset by 1-2 pixels
	# TODO(calco): Adjust position dynamically
	scene_viewport.size = get_viewport().get_visible_rect().size * 2
	scene_viewport.disable_3d = true
	scene_viewport.transparent_bg = true
	scene_viewport.handle_input_locally = false

	var shadow_pixels: SubViewport = $"RenderPasses/ShadowPixelsPass"
	var shadow_pixels_tex: TextureRect = shadow_pixels.get_child(0)
	var shadow_pixels_mat: ShaderMaterial = shadow_pixels_tex.material

	shadow_pixels.size = scene_viewport.size
	shadow_pixels.disable_3d = true
	shadow_pixels.transparent_bg = true
	shadow_pixels.handle_input_locally = false
	shadow_pixels_tex.size = scene_viewport.size

	shadow_pixels_mat.set_shader_parameter(&"u_scene_tex", scene_viewport.get_texture())
	
	shadow_pixels_mat.set_shader_parameter(&"u_light_dir", Vector3(-1, 1, 1 / MAX_HEIGHT))

	# shadow_pixels_mat.set_shader_parameter(&"u_distance", 1.0 / 20.0)

	output_texture.size = shadow_pixels.size
	output_texture.texture = shadow_pixels.get_texture()

func _setup_scene() -> void:
	for occluder in _get_children_with_group(get_tree().root, OCCLUDER_GROUP):
		if occluder is Node2D:
			var cp = occluder.duplicate(0)
			scene_viewport.add_child(cp)
			sync_refs.append(ObjSync.new(occluder, cp))
			# occluder.visible = false
		# if occluder is Occluder:
		# 	occluder.material = occluder_material

func _get_children_with_group(node: Node, grp: StringName) -> Array[Node]:
	var q: Array[Node] = [node]
	var c: Array[Node] = []
	while not q.is_empty():
		var n = q.pop_front()
		if n.is_in_group(grp):
			c.append(n)
		for child in n.get_children():
			q.append(child)
	return c
