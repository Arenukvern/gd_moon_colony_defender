extends Asteroid

class_name IceWateredAsteroid

export var debug_target_position: = Vector2.ZERO

func _ready() -> void:
	randomize()
	var start_distance_surface_edge = rand_range( 1, AsteroidsState.asteroidStartMaxDistance)
	randomize()
	var start_x_position: = rand_range( -10,  _screen_dimension.x)
	global_position = Vector2(start_x_position, - start_distance_surface_edge)
	define_target_position()

	var iceResource:= BaseResourceFactory.getWaterIce(mass)
	health_damage_system.initSystem( [ iceResource ] )

func define_target_position()-> void:
	if debug_target_position != Vector2.ZERO :
		target_global_position = debug_target_position
	else:
		randomize()
		var target_x_position: = rand_range( 1,  _screen_dimension.x)
		target_global_position = Vector2(target_x_position,_screen_dimension.y) 

func _physics_process(delta: float) -> void:
	if global_position.distance_to(target_global_position) < DISTANCE_THRESHOLD :
		return
	_velocity = Steering.follow(
		_velocity,
		global_position,
		target_global_position,
		max_speed,
		mass
	)
	_velocity = move_and_slide(_velocity)
#	_sprite.rotation = _velocity.angle()
	collides_check()
	
