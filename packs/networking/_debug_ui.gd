extends Node

@export var ui_main: Node2D = null
@export var ui_server: Node2D = null
@export var ui_client: Node2D = null

var ui_inp_server_ip: LineEdit = null

func _enter_tree() -> void:
	ui_main.visible = true
	ui_server.visible = false
	ui_client.visible = false

	ui_inp_server_ip = $"MainMenu/IpEdit"

	$"MainMenu/Join".pressed.connect(_handle_join_server)
	$"MainMenu/Host".pressed.connect(_handle_host_server)

	$"ServerOwner/Start".pressed.connect(_handle_server_start)

	NetworkManager.n_on_client_started.connect(_ui_client)
	NetworkManager.n_on_server_started.connect(_ui_server)


func _handle_host_server() -> void:
	NetworkManager.n_create_server()

func _handle_join_server() -> void:
	CLog.trace("Handle join server pressed.")
	var server_ip = ui_inp_server_ip.text
	if server_ip == "" or _is_not_ip(server_ip):
		CLog.warn("Provided ip was not an ip lol")
		return
	NetworkManager.n_create_client(server_ip)

# TODO(calco): Do this lol
func _handle_server_start() -> void:
	NetworkManager.n_create_server()

func _is_not_ip(_address: String) -> bool:
	return false

func _ui_client() -> void:
	ui_main.visible = false
	ui_server.visible = false
	ui_client.visible = true

func _ui_server() -> void:
	ui_main.visible = false
	ui_server.visible = true
	ui_client.visible = false
