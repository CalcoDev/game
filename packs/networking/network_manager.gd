extends Node

const MAX_CHANNEL_COUNT: int = 32

const SERVER_PORT: int = 25565

const ID_INVALID: int = -1

# A class supposed to handle almost all things related to networking.
var n_is_server: bool = false
var n_server_id: int = ID_INVALID
var n_id: int = ID_INVALID

# [int(id) -> DummyClient]
var n_clients: Dictionary = {}
var n_peer: ENetMultiplayerPeer = null

signal n_on_server_started()
signal n_on_client_started()

func n_get_player(id: int) -> DummyClient:
	return n_clients[id]

func _exit_tree() -> void:
	if n_peer != null:
		CLog.info("Peer was still on when network manager was disconnected.")
		n_close_peer()
	if multiplayer.multiplayer_peer != null:
		CLog.info("Multiplayer Peer (Godot) was still on when network manager was disconnected.")
		multiplayer.multiplayer_peer = null

func n_create_server() -> void:
	if n_peer != null:
		CLog.warn("Peer was not null when trying to create new server! Closing ...")
		n_close_peer()
	if multiplayer.multiplayer_peer != null:
		CLog.warn("Multiplayer peer (Godot) was not null when trying to create new server! Closing ...")
		multiplayer.multiplayer_peer = null
	
	CLog.info("Creating new peer...")
	n_peer = ENetMultiplayerPeer.new()
	_setup_peer_events()
	
	var res = n_peer.create_server(SERVER_PORT, 32, MAX_CHANNEL_COUNT)
	if res == ERR_CANT_CREATE:
		CLog.error("Hello thjere was issue creating serrver.")
		return
	CLog.info("Created server with port [%s]." % SERVER_PORT)

	multiplayer.multiplayer_peer = n_peer
	n_id = n_peer.get_unique_id()
	n_is_server = true
	n_server_id = n_id
	n_on_server_started.emit()

func n_close_peer() -> void:
	CLog.info("Closing peer...")
	n_peer.close()
	n_peer = null
	multiplayer.multiplayer_peer = null
	# TODO(calco): Handle disconnect logic etcetc

func n_create_client(server_ip: String) -> void:
	if n_peer != null:
		CLog.warn("Peer was not null when trying to create new client! Closing ...")
		n_close_peer()
	if multiplayer.multiplayer_peer != null:
		CLog.warn("Multiplayer peer (Godot) was not null when trying to create new client! Closing ...")
		multiplayer.multiplayer_peer = null
	
	CLog.info("Creating new peer...")
	n_peer = ENetMultiplayerPeer.new()
	_setup_peer_events()
	
	var res = n_peer.create_client(server_ip, SERVER_PORT, MAX_CHANNEL_COUNT)
	if res == ERR_CANT_CREATE:
		CLog.error("Hello thjere was issue creating client and or connecting to server!.")
		return
	CLog.info("Created client on port [%s] and connected to server with addr [%s]" % ["UNKNOWN HELP", server_ip])

	multiplayer.multiplayer_peer = n_peer
	n_id = n_peer.get_unique_id()
	n_is_server = false
	
	n_on_client_started.emit()

func _setup_peer_events() -> void:
	n_peer.peer_connected.connect(_on_peer_connected)
	n_peer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
	if n_is_server:
		CLog.info("Peer [%d] connected to server." % id)
		n_clients[id] = DummyClient.new(id)
		# TODO(calco): Handle actual joining logic (tell ... about ...)
	# TODO(calco): Figure out what to do if client / if there is anything to be done

func _on_peer_disconnected(id: int) -> void:
	if n_is_server:
		CLog.info("Peer [%d] disconnected." % id)
		n_clients.erase(id)
		# TODO(calco): Handle connection logic
	# TODO(calco): Handle server himself disconnect lol
