extends Area2D

class_name PlaceSelector

var verticalPosition: float = 400.0
onready var _screen_dimension = OS.get_window_size()
func _ready():
	verticalPosition = _screen_dimension.y - 100
	_change_position()

func _physics_process(delta):
	_change_position()	

func _change_position()->void:
	var x = get_global_mouse_position().x
	global_position = Vector2(x,verticalPosition)
