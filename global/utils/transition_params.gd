class_name TransitionParams

var name: StringName = &""
var play_in: bool = true
var play_out: bool = true
var await_scene_load: bool = true

@warning_ignore("shadowed_variable")
func _init(name: StringName, play_in: bool, play_out: bool, await_scene_load: bool) -> void:
	self.name = name
	self.play_in = play_in
	self.play_out = play_out
	self.await_scene_load = await_scene_load
