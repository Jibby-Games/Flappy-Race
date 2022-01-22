extends Node


const CLIENT_SCRIPT = "res://client/singletons/globals.gd"


func _ready() -> void:
	pass


func change_to_client() -> void:
	var script = load(CLIENT_SCRIPT)
	self.set_script(script)
	self._ready()
