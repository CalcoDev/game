extends Node

signal on_pre_process()
enum ProcessList {
	Game = -100,
	Lights = -10,
	HDWorld = -5,
	Default = 0,
}

var _dbg_instance_id = -1

func _enter_tree() -> void:
	process_priority = ProcessList.Game
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

func _process(_delta: float) -> void:
	on_pre_process.emit()

# Scene switching utils (should be separate object?)

# change scene, [transition], [wait for end?]

# Changes scene to a node (in / out of tree)
const TRANSITION_FADE: StringName = &"fade"

@onready var _scene_transition_anim: AnimationPlayer = $"HDWorld-HighRes/CanvasLayer/AnimationPlayer"
func change_scene(node: Node, transition_name: StringName = TRANSITION_FADE) -> void:
	if _scene_transition_anim.is_playing():
		_scene_transition_anim.stop()
	_scene_transition_anim.play(transition_name + "_in")
	_scene_transition_anim.advance(0)
	await _scene_transition_anim.animation_finished
	HDWorld.setup_scene_from_node(node, HDWorld.SceneLoadMode.Replace)
	# TODO(calco): Probably await some scene setup here or sth
	_scene_transition_anim.play(transition_name + "_out")
	_scene_transition_anim.advance(0)
	await _scene_transition_anim.animation_finished

func change_scene_file(filepath: String, transition_name: StringName = TRANSITION_FADE) -> void:
	var scene_inst = load(filepath).instantiate()
	await change_scene(scene_inst, transition_name)
	print("ooga booga changed scene")
