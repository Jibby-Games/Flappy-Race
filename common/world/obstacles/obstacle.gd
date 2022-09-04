extends Node2D


class_name Obstacle


var generated := false
var length: int


onready var Checkpoint: Area2D = $"%Checkpoint"
onready var PointArea: Area2D = $"%PointArea"


func _ready() -> void:
	if generated == false:
		push_error("Obstacle (%s) must be generated before adding it to the scene" % name)
	if length == 0:
		push_error("Obstacle (%s) length must be greater than 0" % name)


func generate(game_rng: RandomNumberGenerator) -> void:
	do_generate(game_rng)
	length = calculate_length()
	generated = true


func do_generate(_game_rng: RandomNumberGenerator) -> void:
	push_error("Obstacle (%s) must override do_generate when extending the class!" % name)


func calculate_length() -> int:
	push_error("Obstacle (%s) must override calculate_length when extending the class!" % name)
	return 0
