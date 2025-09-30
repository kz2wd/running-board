extends VBoxContainer

@onready var boot_menu: BootMenu = $"../.."

@onready var ip_input: LineEdit = $HBoxContainer/IpInput

@onready var join_server_button: Button = $JoinServerButton
@onready var back_button: Button = $BackButton


func _ready() -> void:
	join_server_button.connect("button_down", _join_button_pressed)
	back_button.connect("button_down", _go_back)


func _join_button_pressed():
	GameClient.start_client(ip_input.text, 9500)


func _go_back():
	boot_menu.go_back()
