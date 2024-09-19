class_name AudioQueue extends Node

signal on_start_playing(id: String)
signal on_stop_playing(id: String)

@export var stream_player_count: int = 4
@export var bus: String = &"SFX"

var is_playing: bool = false

var _free_stream_players: Array[AudioStreamPlayer] = []
var _in_use_stream_players: Dictionary[String, AudioStreamPlayer] = {}
var _players_to_id: Dictionary[AudioStreamPlayer, String] = {}

var _queue: Array[AudioIdent] = []

class AudioIdent:
	var stream: AudioStream
	var id: String
	var volume: float

func _ready() -> void:
	for i in stream_player_count:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = bus
		add_child(player)
		player.finished.connect(_on_player_finished.bind(player))
		_free_stream_players.append(player)

func play(id: String, stream: AudioStream, volume: float) -> void:
	var ident: AudioIdent = AudioIdent.new()
	ident.stream = stream
	ident.id = id
	ident.volume = volume
	_queue_item(ident)

func stop(id: String) -> void:
	var player = _in_use_stream_players.get(id, null)
	if player == null:
		return
	player.stop()
	_in_use_stream_players.erase(id)
	_players_to_id.erase(player)

func _queue_item(ident: AudioIdent) -> void:
	if _free_stream_players.size() > 0:
		var player: AudioStreamPlayer = _free_stream_players.pop_back()
		_play_audio(player, ident)
	else:
		_queue.push_back(ident)

func _play_audio(player: AudioStreamPlayer, ident: AudioIdent) -> void:
	player.volume_db = linear_to_db(ident.volume)
	player.stream = ident.stream
	player.play()
	on_start_playing.emit(ident.id)
	_in_use_stream_players[ident.id] = player
	_players_to_id[player] = ident.id

func _on_player_finished(player: AudioStreamPlayer) -> void:
	var id: String = _players_to_id[player]
	on_stop_playing.emit(id)
	if _queue.size() > 0:
		var ident: AudioIdent = _queue.pop_front()
		_play_audio(player, ident)
	else:
		_free_stream_players.append(player)
