extends StaticBody2D

onready var UpperSprite = $UpperSprite
onready var UpperCollider = $UpperCollider
onready var LowerSprite = $LowerSprite
onready var LowerCollider = $LowerCollider

var base_wall_height = 640
var speed = 2
var gap = 200


func _ready():
	set_gap(gap)


func _physics_process(_delta):
	position -= Vector2(speed, 0)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func set_gap(size):
	var pos = base_wall_height + (size / 2)
	UpperSprite.position.y = -pos
	UpperCollider.position.y = -pos
	LowerSprite.position.y = pos
	LowerCollider.position.y = pos
