extends Node

const AUTOHANDLE_GROUP = "hdworld_autohandle"
const PERMA_GROUP = "hdworld_permanent"
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

# [parent node -> [low/high res node]]
# Helps remove stuff
var ownership_dict: Dictionary = {}

func add_ownership(scene: Node, object: Node) -> void:
    if not scene in ownership_dict:
        ownership_dict[scene] = []
    ownership_dict[scene].append(object)

func _enter_tree() -> void:
    box = $"Box"
    lowres_viewport = $"Box/LowresViewport"
    highres_viewport = $"HighresViewport"

    lowres_viewport.size = settings.desired_res + Vector2i(2, 2) # padding for camera
    # lowres_viewport.size = settings.desired_res

    # TODO(calco): Update position accordingly
    box.size = lowres_viewport.size

    settings.on_pixel_offset_changed.connect(_update_pixel_offset)

    # TODO(calco): Compute the number of autoloads at runtime
    var root = get_tree().get_root()
    var loaded_scene = root.get_child(root.get_child_count() - 1)
    setup_scene_from_node(loaded_scene, SceneLoadMode.Replace)

    # TODO(calco): Reset the default texture filter alg to linear or sth
    # in order to ensure proper high res scaling

    get_tree().node_added.connect(_handle_node_added)
    get_tree().node_removed.connect(_handle_node_removed)

    setup_viewport_scale()
    get_viewport().size_changed.connect(_handle_viewport_size_change)

# TODO(calco): Maybe implement this? For now I don't think I'll need it / would rather manually control
# TODO(calco): Maybe even have this as a group / flag (?)
func _handle_node_added(node: Node) -> void:
    if node.is_in_group(AUTOHANDLE_GROUP):
        print("node was added: ", node.name)

# TODO(calco): By default I kinda want to handle all of them lol
func _handle_node_removed(node: Node) -> void:
    if unsetup_scene_from_node(node):
        print("REMOVED HDWORLD NODES CUZ OWNER DED")
    if node.is_in_group(AUTOHANDLE_GROUP):
        print("node was removed: ", node.name)

func _update_pixel_offset(pixel_offset: Vector2) -> void:
    box.material.set_shader_parameter(&"u_cam_offset", pixel_offset)

func setup_viewport_scale() -> void:
    box.scale = get_viewport().get_visible_rect().size / Vector2(settings.desired_res)
    box.global_position -= box.scale

func setup_scene_from_node(scene: Node, mode: SceneLoadMode) -> void:
    for lowres in _get_children_with_group(scene, LOWRES_GROUP):
        if mode == SceneLoadMode.Replace:
            for child in lowres_viewport.get_children():
                # TODO(calco): Just make a child to not iterate all the time lol
                if not child.is_in_group(PERMA_GROUP):
                    child.queue_free()
        if lowres != null:
            scene.remove_child(lowres)
            lowres.owner = null
            lowres_viewport.add_child(lowres)
            add_ownership(scene, lowres)
    
    for highres in _get_children_with_group(scene, HIGHRES_GROUP):
        if mode == SceneLoadMode.Replace:
            for child in highres_viewport.get_children():
                # TODO(calco): Just make a child to not iterate all the time lol
                if not child.is_in_group(PERMA_GROUP):
                    child.queue_free()
        if highres != null:
            scene.remove_child(highres)
            highres.owner = null
            highres_viewport.add_child(highres)
            add_ownership(scene, highres)

# TODO(calco): This is debatbale?
func unsetup_scene_from_node(scene: Node) -> bool:
    if not scene in ownership_dict:
        return false
    for node in ownership_dict[scene]:
        if node == null:
            continue
        # TODO(calco): Should these live longer?
        if not node.is_in_group("PERMA_GROUP"):
            node.process_mode = ProcessMode.PROCESS_MODE_DISABLED
            node.queue_free()
    return true

func _handle_viewport_size_change() -> void:
    # TODO(calco): Properly handle viewport resizes
    setup_viewport_scale()

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

func _get_first_child_with_group(node: Node, grp: StringName) -> Node:
    var q: Array[Node] = [node]
    while not q.is_empty():
        var n = q.pop_front()
        if n.is_in_group(grp):
            return n
        for child in n.get_children():
            q.append(child)
    return null
