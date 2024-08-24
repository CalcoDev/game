class_name CLog

enum Level {
	Trace,
	Info,
	Warn,
	Error,
	Fatal,
}

static var log_file: FileAccess = null
static var log_level: Level = Level.Trace
static var log_console_pretty: bool = true

static func set_log_file(path: String) -> void:
	if path == null || path == "":
		log_file = null
	else:
		log_file = FileAccess.open(path, FileAccess.WRITE)

static func trace(message: String) -> void:
	_output_string(_get_message_format(Level.Trace, message))

static func info(message: String) -> void:
	_output_string(_get_message_format(Level.Info, message))

static func warn(message: String) -> void:
	_output_string(_get_message_format(Level.Warn, message))

static func error(message: String) -> void:
	_output_string(_get_message_format(Level.Error, message))

static func fatal(message: String) -> void:
	_output_string(_get_message_format(Level.Fatal, message))

static func _output_string(s: String) -> void:
	if log_file == null:
		print_rich(s)
	else:
		log_file.store_line(s)

const _lvl_arr = ["Trace", "Info", "Warn", "Error", "Fatal"]
const _lvl_col = ["gray", "green", "yellow", "red", "magenta"]
static func _get_message_format(level: Level, message: String) -> String:
	var date = Time.get_datetime_dict_from_system()
	var formatted_date_time = "%d/%02d/%02d %02d:%02d:%02d" % [
		date["year"],
		date["month"],
		date["day"],
		date["hour"],
		date["minute"],
		date["second"]
	]
	var bbcode_message: String
	if log_file == null and log_console_pretty:
		bbcode_message = "[color=gray]%s[/color] [color=%s]%s[/color]: [color=white]%s[/color]" % [
			formatted_date_time,
			_lvl_col[level],
			_lvl_arr[level],
			message
		]
	else:
		bbcode_message = "%s %s: %s" % [
			formatted_date_time,
			_lvl_arr[level],
			message
		]
	return bbcode_message
