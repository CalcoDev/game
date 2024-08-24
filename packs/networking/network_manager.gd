extends Node

const CLIENT_CHANNEL: int = 1
const MAX_CHANNEL_COUNT: int = 32

const SERVER_PORT: int = 25565

const ID_INVALID: int = -1

# A class supposed to handle almost all things related to networking.
var n_is_server: bool = false
var n_server_id: int = ID_INVALID
var n_id: int = ID_INVALID

var n_peer: ENetMultiplayerPeer = null

var n_server: DummyServer = null # CLIENT ONLY
# [int(id) -> DummyClient]
var n_clients: Dictionary = {} # SERVER ONLY

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

func n_create_peer() -> void:
	n_peer = ENetMultiplayerPeer.new()
	CLog.info("Created new peer with unknown ID for now (waiting until connection ...)")
	_setup_peer_events()

func n_create_server() -> void:
	if n_peer != null:
		CLog.warn("Peer was not null when trying to create new server! Closing ...")
		n_close_peer()
	if multiplayer.multiplayer_peer != null:
		CLog.warn("Multiplayer peer (Godot) was not null when trying to create new server! Closing ...")
		multiplayer.multiplayer_peer = null
	
	n_create_peer()
	var res = n_peer.create_server(SERVER_PORT, 32, MAX_CHANNEL_COUNT)
	if res == ERR_CANT_CREATE:
		CLog.error("Hello thjere was issue creating serrver.")
		return
	CLog.info("Created server with port [%s]." % SERVER_PORT)
	CLog.info("Received peer id [%d]" % n_peer.get_unique_id())

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
	
	n_create_peer()
	
	var res = n_peer.create_client(server_ip, SERVER_PORT, MAX_CHANNEL_COUNT)
	if res == ERR_CANT_CREATE:
		CLog.error("An issue occurred while creating client and / or connecting to server!.")
		return
	CLog.info("Created client on port [%s] and connected to server with addr [%s]" % ["UNKNOWN HELP", server_ip])
	CLog.info("Received peer id [%d]" % n_peer.get_unique_id())

	multiplayer.multiplayer_peer = n_peer
	n_id = n_peer.get_unique_id()
	n_is_server = false
	
	n_on_client_started.emit()

func _setup_peer_events() -> void:
	n_peer.peer_connected.connect(_on_peer_connected)
	n_peer.peer_disconnected.connect(_on_peer_disconnected)

# NOTE(calco): func is called on any peer, to bring everyone up to date effectively.
# a (client) connects to B (server) => B is told of a, a is told of everyone on B (afaik)
# Assumption SEEMS to be correct, but remember current model is [a, b, c, d, e] => S. 
# No inter client connections. All talks happen over server.
func _on_peer_connected(id: int) -> void:
	CLog.info("Peer [%d] connected to own peer." % id)
	if n_is_server:
		n_clients[id] = DummyClient.new(id)
		rpc_announce_player_joined.rpc(DummyPlayer.new(id))

# NOTE(calco): func is called on any peer, to bring everyone up to date effectively.
# a (client) connects to B (server) => B is told of a, a is told of everyone on B (afaik)
# Assumption SEEMS to be correct, but remember current model is [a, b, c, d, e] => S. 
# No inter client connections. All talks happen over server.
func _on_peer_disconnected(id: int) -> void:
	CLog.info("Peer [%d] disconnected." % id)
	if n_is_server:
		n_clients.erase(id)
		rpc_announce_player_disconnect.rpc(id)

	# todo(calco): see if the bellow todo is still a todo
	# TODO(calco): Handle server himself disconnect lol




####################################################
################ RPC PEER FUNCTIONS ################
####################################################




@rpc("any_peer", "call_local", "reliable", CLIENT_CHANNEL)
func rpc_announce_player_joined(player: DummyPlayer) -> void:
	CLog.info("Woah! Player joined with stuff: %s" % player.to_string())
	# TODO(calco): Handle player joining lol

@rpc("any_peer", "call_remote", "reliable", CLIENT_CHANNEL)
func rpc_announce_player_disconnect(player_id: int) -> void:
	CLog.info("Oh nooo! Player [%d] left! How sad >:( ...." % player_id)
	# TODO(calco): Handle player disconnecting lol
