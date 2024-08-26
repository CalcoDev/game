extends Node

const LOWRES_GROUP = "hdworld_lowres"
const HIGHRES_GROUP = "hdworld_highres"

@export var settings: HDWorldViewportSettings = null

var camera: Camera2D = null
var cam_base_pos: Vector2 = Vector2.ZERO

var lowres_viewport: SubViewport = null
var highres_viewport: Node = null

# TODO(calco): Set up sane defaults as we go along the way.

enum SceneLoadMode {
    Add = 0,
    Replace = 1
}

func _enter_tree() -> void:
    process_priority = Game.ProcessList.HDWorld + 1
    camera = $"Camera2D"
    lowres_viewport = $"Box/LowresViewport"
    highres_viewport = $"HighresViewport"

    lowres_viewport.size = settings.desired_res
    # TODO(calco): Just make this a getter at this point
    if settings.enable_smooth_pixelart_camera:
        lowres_viewport.size += settings.smooth_pixelart_camera_pad * 2

    # TODO(calco): Compute the number of autoloads at runtime
    var root = get_tree().get_root()
    var loaded_scene = root.get_child(root.get_child_count() - 1)
    setup_scene_from_node(loaded_scene, SceneLoadMode.Replace)

    # TODO(calco): Reset the default texture filter alg to linear or sth
    # in order to ensure proper high res scaling

    setup_viewport_scale()
    # get_tree().get_root().size_changed.connect(_handle_window_size_change)
    get_viewport().size_changed.connect(_handle_viewport_size_change)

func _process(_delta: float) -> void:
    if settings.enable_smooth_pixelart_camera:
        # print(settings._curr_pixel_offset)
        camera.global_position = cam_base_pos - settings._curr_pixel_offset * 5
    # pass

func setup_viewport_scale() -> void:
    cam_base_pos = get_viewport().get_visible_rect().size / 2.0
    camera.global_position = cam_base_pos
    print(cam_base_pos)

    # TODO(calco): Figure out how to scale without breaking everything.
    var box = lowres_viewport.get_parent()
    box.scale = get_viewport().get_visible_rect().size / Vector2(settings.desired_res)
    # TODO(calco): This should allow changing dynamically, whenever I want to
    if settings.enable_smooth_pixelart_camera:
        box.global_position -= Vector2(settings.smooth_pixelart_camera_pad) * 5
    # print(box.global_position)

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
