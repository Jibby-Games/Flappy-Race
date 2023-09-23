extends Node2D

export(PackedScene) var bomb
var timer := 0.0

func _ready() -> void:
	$Player.coins = 100
	$Player.position.x = 10000
	spawn_bomb()


func _physics_process(delta: float) -> void:
	timer += delta
	if timer > 3:
		spawn_bomb()
		timer = 0.0
	if $Player.global_position.y > 0.0:
		$Player.do_flap()


func spawn_bomb() -> void:
	var inst : Node2D = bomb.instance()
	inst.global_position = $start.global_position
	inst.target = $Player
	add_child(inst)
