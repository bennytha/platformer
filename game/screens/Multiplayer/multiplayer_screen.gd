extends Node
@onready var level: Node = $Level
@onready var ip_line_edit: LineEdit = $UIMenu/PanelContainer/VBoxContainer/NotHostView/IPLineEdit
@onready var status_label: Label = $UIMenu/PanelContainer/VBoxContainer/StatusLabel
const M_LEVEL_1 = preload("uid://bitwr6n8pb8bi")
@onready var ui_menu: Control = $UIMenu
@onready var not_host_view: HBoxContainer = $UIMenu/PanelContainer/VBoxContainer/NotHostView
@onready var host_view: HBoxContainer = $UIMenu/PanelContainer/VBoxContainer/HostView

func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	Lobby.server_disconnected.connect(_on_lobby_server_disconnected)

func _on_host_pressed() -> void:
	host_view.show()
	not_host_view.hide()
	status_label.text = 'Hosting'
	Lobby.create_game()

func _on_join_pressed() -> void:
	Lobby.join_game(ip_line_edit.text)
	status_label.text = 'Connecting...'

func _on_start_pressed() -> void:
	toggle_ui.rpc()
	change_scene(M_LEVEL_1)

func _on_connection_failed():
	host_view.hide()
	not_host_view.show()
	status_label.text = 'Failed to connect'

func _on_connected_server():
	not_host_view.hide()
	status_label.text = 'Connected to server'

func _on_server_disconnected() -> void:
	_on_lobby_server_disconnected()

func _on_lobby_server_disconnected() -> void:
	host_view.hide()
	not_host_view.show()
	status_label.text = 'Server disconnected'
	clear_level()
	ui_menu.visible = true

func clear_level() -> void:
	for child in level.get_children():
		level.remove_child(child)
		child.queue_free()
	
@rpc('call_local','authority','reliable')
func toggle_ui():
	ui_menu.visible = false
	
func change_scene(scene):
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
		
