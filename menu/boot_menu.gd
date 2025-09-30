extends Control
class_name BootMenu

@onready var host_button: Button = $ContentContainer/SelectionContainer/HostButton
@onready var join_button: Button = $ContentContainer/SelectionContainer/JoinButton

@onready var content_container: Control = $ContentContainer

@onready var join_container: VBoxContainer = $ContentContainer/JoinContainer
@onready var selection_container: VBoxContainer = $ContentContainer/SelectionContainer

@onready var user_name_input: LineEdit = $UserNameInput

func _ready() -> void:
	host_button.connect("button_down", _host_button_pressed)
	join_button.connect("button_down", _join_button_pressed)

const LOBBY = preload("uid://cpn13l2lxicjb")

func _host_button_pressed():
	GameServer.start_server(user_name_input.text)
	# Assume we are already connected since we are the server
	get_tree().scene_changed.connect(GameServer.init_lobby_on_server)
	get_tree().change_scene_to_packed(LOBBY)
	

func _join_button_pressed():
	_enable_selection(join_container)

func go_back():
	_enable_selection(selection_container)

func _hide_all_containers():
	for child in content_container.get_children():
		child.visible = false

func _enable_selection(container):
	_hide_all_containers()
	container.visible = true
