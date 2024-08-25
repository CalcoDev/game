class_name Lights
extends Node

const EMITTER_GROUP: StringName = &"lights_emitter"
const OCCLUDER_GROUP: StringName = &"lights_occluder"

var lights_viewport: SubViewport

var _voronoi_passes: Array[SubViewport] = []

# TODO(calco): Should somehow set this up using viewport sizes in here, not in editor, but oh well
func _enter_tree() -> void:
	# Set up lights
	lights_viewport = $"LightViewport"
	for emitter in _get_children_with_group(self, EMITTER_GROUP):
		self.remove_child(emitter)
		emitter.owner = null
		lights_viewport.add_child(emitter)
	for occluder in _get_children_with_group(self, OCCLUDER_GROUP):
		self.remove_child(occluder)
		occluder.owner = null
		lights_viewport.add_child(occluder)

	# Set up voronoi
	var voroinoi_tex: TextureRect = $"VoronoiViewport/TextureRect"
	(voroinoi_tex.material as ShaderMaterial).set_shader_parameter(&"u_input_tex", lights_viewport.get_texture())

	# Set up voronoi jump passes
	var passes = ceil(log(max(get_viewport().size.x, get_viewport().size.y)) / log(2.0))
	for i in passes:
		var offset = pow(2, passes - i - 1)
		var render_pass
		if i == 0:
			render_pass = $"JumpFloodPass"
		else:
			render_pass = $"JumpFloodPass".duplicate(0)
			add_child(render_pass)
		render_pass.get_child(0).material = render_pass.get_child(0).material.duplicate(0)
		_voronoi_passes.append(render_pass)

		var input_texture = $"VoronoiViewport".get_texture()
		if i > 0:
			input_texture = _voronoi_passes[i - 1].get_texture()

		render_pass.get_child(0).material.set_shader_parameter(&"u_level", i)
		render_pass.get_child(0).material.set_shader_parameter(&"u_max_steps", passes)
		render_pass.get_child(0).material.set_shader_parameter(&"u_offset", offset)
		render_pass.get_child(0).material.set_shader_parameter(&"u_input_tex", input_texture)
	
	($"DistanceField/TextureRect".material as ShaderMaterial).set_shader_parameter(&"u_input_tex", _voronoi_passes[_voronoi_passes.size() - 1].get_texture())
	$"GIPass/TextureRect".material.set_shader_parameter("u_rays_per_pixel", 64)
	$"GIPass/TextureRect".material.set_shader_parameter("u_distance_data", $"DistanceField".get_texture())
	$"GIPass/TextureRect".material.set_shader_parameter("u_scene_data", $"LightViewport".get_texture())
	$"GIPass/TextureRect".material.set_shader_parameter("u_emission_multi", 1.0)
	$"GIPass/TextureRect".material.set_shader_parameter("u_max_raymarch_steps", 128)
	
	$"TextureRect".texture = $"GIPass".get_texture()

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
