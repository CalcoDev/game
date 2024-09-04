class_name TransitionParams

var name: StringName = &""
var play_in: bool = true
var play_out: bool = true

func _init(name: StringName, play_in: bool, play_out: bool) -> void:
	self.name = name
	self.play_in = play_in
	self.play_out = play_out
