extends Node

var _delta_time: float = 0.0
var _fixed_delta_time: float = 0.0

func get_delta() -> float:
	return _delta_time

func get_fixed_delta() -> float:
	return _fixed_delta_time


signal on_deferred()
signal on_pre_process(float)
@warning_ignore("unused_signal")
signal on_post_process(float)
enum ProcessList {
	PreProcess = -999,
	Game = -100,
	Lights = -10,
	HDWorld = -5,
	Default = 0,
	PostProcess = 999
}

var _dbg_instance_id = -1

func _enter_tree() -> void:
	process_priority = ProcessList.Game
	$"PreProcess".process_priority = ProcessList.PreProcess
	$"PostProcess".process_priority = ProcessList.PostProcess
	
	var args = Array(OS.get_cmdline_args())
	if args.size() == 2:
		_dbg_instance_id = int(args[1])
		CLog.set_log_file("res://logs/instance_%d.log" % _dbg_instance_id)
		CLog.info("Log file for instance id [%d]" % _dbg_instance_id)
	
	# var data = DummyPlayer.new(52)
	# print(data)
	# var bytes = Serializer.Serialize(data)
	# print("Bytes: ", bytes)
	# var reconstructed: DummyPlayer = Serializer.Deserialize(DummyPlayer, bytes)
	# print(reconstructed)

func _process(delta: float) -> void:
	_delta_time = delta
	on_pre_process.emit()

	if Input.is_action_just_pressed("FULLSCR"):
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _physics_process(delta: float) -> void:
	_fixed_delta_time = delta

func await_deferred() -> Signal:
	var def_sig = Signal(on_deferred)
	def_sig.emit.call_deferred()
	return def_sig

# Scene switching utils (should be separate object?)

# change scene, [transition], [wait for end?]

# Changes scene to a node (in / out of tree)
const TRANSITION_FADE: StringName = &"fade"

@onready var _scene_transition_anim: AnimationPlayer = $"CanvasLayer/AnimationPlayer"
func change_scene(node: Node, params: TransitionParams) -> void:
	if _scene_transition_anim.is_playing():
		_scene_transition_anim.stop()
	if params.play_in:
		_scene_transition_anim.play(params.name + "_in")
		_scene_transition_anim.advance(0)
		await _scene_transition_anim.animation_finished
	# HDWorld.setup_scene_from_node(node, HDWorld.SceneLoadMode.Replace)
	# TODO(calco): Probably await some scene setup here or sth
	# do sth

	if params.await_scene_load:
		await _handle_scene_load_unload(node)
	else:
		_handle_scene_load_unload(node)

	if params.play_out:
		_scene_transition_anim.play(params.name + "_out")
		_scene_transition_anim.advance(0)
		await _scene_transition_anim.animation_finished

# TODO(Calco): Await for stuff to be done here ig
func _handle_scene_load_unload(node: Node) -> void:
	get_tree().call_deferred("unload_current_scene")
	await await_deferred()
	get_tree().root.add_child(node)
	node.owner = get_tree().root
	get_tree().current_scene = node

func change_scene_file(filepath: String, params: TransitionParams) -> void:
	var scene_inst = load(filepath).instantiate()
	await change_scene(scene_inst, params)
