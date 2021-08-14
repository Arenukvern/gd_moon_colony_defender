extends Node

onready var root: Node = $'.'
onready var uiState: Node = get_tree().get_root().get_node("/root/UIState")
onready var asteroidSpawnQuantity: = 1.0
onready var asteroidStartMaxDistance: = 300.0

const waterIcedAsteroid: = preload('res://objects/asteroid/ice_watered/IceWateredAsteroid.tscn')

var _timer: = Timer.new()
var seconds_until_spawn: = 7.0 setget set_seconds_until_spawn
func set_seconds_until_spawn(newTimeSec: float)->void:
	seconds_until_spawn = newTimeSec
	_timer.set_wait_time(newTimeSec)
	
func _ready() -> void:
	_setupTimer()


func _setupTimer()->void:
	# Set timer interval
	
	_timer.set_wait_time(seconds_until_spawn)
	
	# Set it as repeat
	_timer.set_one_shot(false)
	
	# Connect its timeout signal to the function you want to repeat
	_timer.connect("timeout", self, "add_asteroid")
	_timer.set_autostart(true)
	uiState.add_child(_timer)
	
	
func add_asteroid(target_position: Vector2 = Vector2.ZERO)->void:
	for n in range(0,asteroidSpawnQuantity):
		var waterIcedAsteroidInstance: = waterIcedAsteroid.instance()
		waterIcedAsteroidInstance.debug_target_position = target_position
		root.add_child(waterIcedAsteroidInstance)
		uiState.addAsteroidToHighscore()
	
