extends Node


enum ProcessList {
	Game = -1,
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
