extends Node

const LOWRES_GROUP = "hdworld_lowres"
const HIGHRES_GROUP = "hdworld_highres"

@export var settings: HDWorldViewportSettings = null

var cam_base_pos: Vector2 = Vector2.ZERO

var box: SubViewportContainer = null
var lowres_viewport: SubViewport = null
var highres_viewport: Node = null

# TODO(calco): Set up sane defaults as we go along the way.

enum SceneLoadMode {
    Add = 0,
    Replace = 1
}

func _enter_tree() -> void:
    box = $"Box"
    lowres_viewport = $"Box/LowresViewport"
    highres_viewport = $"HighresViewport"

    lowres_viewport.size = settings.desired_res + Vector2i(2, 2) # padding for camera

    settings.on_pixel_offset_changed.connect(_update_pixel_offset)

    # TODO(calco): Compute the number of autoloads at runtime
    var root = get_tree().get_root()
    var loaded_scene = root.get_child(root.get_child_count() - 1)
    setup_scene_from_node(loaded_scene, SceneLoadMode.Replace)

    # TODO(calco): Reset the default texture filter alg to linear or sth
    # in order to ensure proper high res scaling

    setup_viewport_scale()
    get_viewport().size_changed.connect(_handle_viewport_size_change)

func _update_pixel_offset(pixel_offset: Vector2) -> void:
    box.material.set_shader_parameter(&"u_cam_offset", pixel_offset)

func setup_viewport_scale() -> void:
    box.scale = get_viewport().get_visible_rect().size / Vector2(settings.desired_res)
    box.global_position -= box.scale

func setup_scene_from_node(scene: Node, mode: SceneLoadMode) -> void:
    # TODO(calco): atm `_get_first_child_with_group` can return ANY child.
    # We want to limit that to 1st genration
    var lowres = _get_first_child_with_group(scene, LOWRES_GROUP)
    var highres = _get_first_child_with_group(scene, HIGHRES_GROUP)

    if mode == SceneLoadMode.Replace:
        for child in lowres_viewport.get_children():
            child.queue_free()
    if lowres != null:
        scene.remove_child(lowres)
        lowres.owner = null
        lowres_viewport.add_child(lowres)
    
    if mode == SceneLoadMode.Replace:
        for child in highres_viewport.get_children():
            child.queue_free()
    if highres != null:
        scene.remove_child(highres)
        highres.owner = null
        highres_viewport.add_child(highres)

func _handle_viewport_size_change() -> void:
    # TODO(calco): Properly handle viewport resizes
    setup_viewport_scale()

func _get_first_child_with_group(node: Node, grp: StringName) -> Node:
    var q: Array[Node] = [node]
    while not q.is_empty():
        var n = q.pop_front()
        if n.is_in_group(grp):
            return n
        for child in n.get_children():
            q.append(child)
    return null
