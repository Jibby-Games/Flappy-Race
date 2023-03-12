extends MenuControl

var title_scene := "res://client/menu/title/title_screen.tscn"
var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"

onready var error_message = $VBoxContainer/Menu/ErrorMessage
onready var info_message = $VBoxContainer/Menu/InfoMessage
onready var name_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/NameContainer/NameInput


func _ready() -> void:
	name_input.text = Globals.player_name


func _on_NextButton_pressed() -> void:
	if name_input.text.empty():
		show_error("Please enter a name")
		return
	error_message.hide()
	Globals.player_name = name_input.text
	change_menu(server_browser_scene)


func _on_BackButton_pressed() -> void:
	change_menu(title_scene)


func show_info(message: String) -> void:
	error_message.hide()
	info_message.text = message
	info_message.show()


func show_error(message: String) -> void:
	info_message.hide()
	error_message.text = message
	error_message.show()
