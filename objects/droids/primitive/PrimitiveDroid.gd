extends Droid

class_name PrimitiveDroid


export var acceleration_explosive_min: = 300.0
export var acceleration_explosive_max: = 400.0


export var DISTANCE_LANDING_THRESHOLD: = 50.0

var is_droid_landed: bool = false setget , get_is_droid_landed

func get_is_droid_landed()->bool:
	return global_position.distance_to(landing_global_position) <= DISTANCE_LANDING_THRESHOLD
	

var is_droid_in_orbit: bool = false setget , get_is_droid_in_orbit
func get_is_droid_in_orbit() -> bool:
	return global_position.distance_to(orbit_global_position) <= DISTANCE_THRESHOLD
	
var is_droid_going_to_refueling: bool = false setget , get_is_droid_going_to_refueling
func get_is_droid_going_to_refueling() -> bool:
	return target_global_position == platform_global_position
var is_droid_going_to_landing: bool = false setget , get_is_droid_going_to_landing
func get_is_droid_going_to_landing() -> bool:
	return target_global_position == landing_global_position

var is_tractor_beam_has_objects: bool = false setget , get_is_tractor_beam_has_objects
func get_is_tractor_beam_has_objects()->bool:
	return tractor_beam_objects.size() > 0
	

export var fuel_reserve_limit: = 700.0
export var is_drop_droid: = false

# Fuel consumption when droid is not moving
export var idle_fuel_consumption: = 1.0
export var fuel_flying_consumption: = 2.0


export var is_goto_platform_to_refuel_in_any_cases: = false
onready var root: KinematicBody2D = $'.'

# TRACTOR BEAM SECTION
export var is_tractor_beam_enabled:= false setget set_is_tractor_beam_enabled
const TractorBeamScene: = preload('res://objects/droids/primitive/TractorBeam.tscn')
var _tractorBeam: TractorBeam
var _tractorBeamFuelConsumption: float = 0.0

func set_is_tractor_beam_enabled(isEnable: bool)->void:
	is_tractor_beam_enabled = isEnable
	if isEnable :
		if not is_instance_valid(_tractorBeam):
			_acceleration_current = acceleration_for_landing
			_tractorBeam = TractorBeamScene.instance()
			_tractorBeamFuelConsumption = _tractorBeam.fuel_consumption
			root.call_deferred("add_child",_tractorBeam)
	elif is_instance_valid(_tractorBeam):
		_tractorBeam.queue_free()
		_tractorBeamFuelConsumption = 0.0
		tractor_beam_objects.clear()

# TRACTOR BEAM OBJECT
var tractor_beam_objects: Array = []

# SENSOR SECTION
export var is_short_range_sensor_enabled: = false setget set_is_short_range_sensor_enabled
const ShortRangeSensorScene: = preload('res://objects/droids/primitive/ShortRangeSensor.tscn')
var _shortRangeSensor: ShortRangeSensor 
var _sensorFuelConsumption: float = 0.0

func set_is_short_range_sensor_enabled(isEnable: bool)->void:
	is_short_range_sensor_enabled = isEnable
	if isEnable:
		if not is_instance_valid(_shortRangeSensor):
			_shortRangeSensor = ShortRangeSensorScene.instance()
			_shortRangeSensor.connect(
				_shortRangeSensor.signal_name_enable_tractor_beam, 
				self, 
				_shortRangeSensor.signal_func_name_enable_tractor_beam
			)
			_sensorFuelConsumption = _shortRangeSensor.fuel_consumption
			root.add_child(_shortRangeSensor)
	elif is_instance_valid(_shortRangeSensor):
		_shortRangeSensor.queue_free()
		_sensorFuelConsumption = 0.0

# SELECTIONS 
const DroidSelectionScene: = preload('res://objects/droids/primitive/DroidSelection.tscn')
export var is_droid_selected: bool = false setget set_is_droid_selected
var _droid_selection: DroidSelection 
func set_is_droid_selected(isSelect: bool)->void:
	is_droid_selected = isSelect
	if isSelect:
		_droid_selection = DroidSelectionScene.instance()
		root.add_child(_droid_selection)
		self.are_all_waypoints_shown = true
		UIState.isWaypointsManagerOpen = true
#		connect signals to catch all waypoint position changes
		if is_instance_valid(UIState.waypointManager) and (UIState.waypointManager is WaypointsManager):
			_connect_waypoints_manager()

	elif is_instance_valid(_droid_selection) and _droid_selection is DroidSelection: 
		_droid_selection.queue_free()
		self.are_all_waypoints_shown = false
		UIState.isWaypointsManagerOpen = false

func _connect_waypoints_manager()->void:
	UIState.waypointManager.connect(
		UIState.waypointManager.signal_name_waypoint_selected,
		self,
		UIState.waypointManager.signal_func_name_waypoint_selected
	)
	UIState.waypointManager.connect(
		UIState.waypointManager.signal_name_close_waypoints_selection,
		self,
		UIState.waypointManager.signal_func_name_close_waypoints_selection
	)
	UIState.waypointManager.connect(
		UIState.waypointManager.signal_name_reboot_droids_power,
		self,
		UIState.waypointManager.signal_func_name_reboot_droids_power
	)

func _on_reboot_droids_power()->void:
	self.is_all_equipment_enabled = false
	if self.fuel_left > 0:
		target_global_position = platform_global_position
		_acceleration_current = acceleration_initial
		
func _on_close_waypoints_selection()->void:
	self.is_droid_selected = false

func _on_waypoint_selected(arg)->void:
	var waypointPosition: Vector2 = arg.position
	var waypointPositionType: int = arg.position_type
	if self.is_in_movement and not self.is_droid_going_to_refueling and not self.is_tractor_beam_has_objects:
		target_global_position = waypointPosition
	
	match waypointPositionType:
		WaypointFactory.PositionType.ORBIT:
			if self.is_droid_in_orbit:
				target_global_position = waypointPosition
			orbit_global_position = waypointPosition
		WaypointFactory.PositionType.PLATFORM:
			if self.is_droid_in_platform:
				target_global_position = waypointPosition
			platform_global_position = waypointPosition
		WaypointFactory.PositionType.LANDING:
			if self.is_droid_landed or self.is_droid_going_to_landing:
				target_global_position = waypointPosition
				
			landing_global_position = waypointPosition
#	rebuild ui waypoints
	_reposition_waypoints_array()
	self.are_all_waypoints_shown = true

onready var orbitWaypoint = WaypointGd.new()
onready var landingWaypoint = WaypointGd.new()

func _populate_waypoints_array()-> void:
	platformWaypoint.waypoint_scene = WaypointFactory.purple
	orbitWaypoint.waypoint_scene = WaypointFactory.red
	landingWaypoint.waypoint_scene = WaypointFactory.yellow
	_reposition_waypoints_array()
	_waypoints_array = [platformWaypoint, orbitWaypoint, landingWaypoint]
func _reposition_waypoints_array()-> void:
	platformWaypoint.global_position = platform_global_position
	orbitWaypoint.global_position = orbit_global_position
	landingWaypoint.global_position = landing_global_position

# PATH

# landing asteroids position
var landing_global_position:= Vector2.ZERO
# stationary orbit to catch asteroids position
var orbit_global_position:= Vector2.ZERO
# position to fly



# how many px droid already flied
var _total_flying_distance: = 0.0



onready var _sprite = $green
onready var _screen_dimension = OS.get_window_size()


var is_all_equipment_enabled:bool = false setget set_is_all_equipment_enabled, get_is_all_equipment_enabled

func set_is_all_equipment_enabled(isEnable: bool)->void:
	is_all_equipment_enabled = isEnable
	if isEnable:
		self.is_short_range_sensor_enabled = true
		self.is_tractor_beam_enabled = true
	else:
		self.is_short_range_sensor_enabled = false		
		self.is_tractor_beam_enabled = false
		
func get_is_all_equipment_enabled()->bool:
	return self.is_short_range_sensor_enabled || self.is_tractor_beam_enabled

func _ready() -> void:
	randomize()
	self.mass_capacity_kg = 10
	_acceleration_explosition = rand_range(acceleration_explosive_min, acceleration_explosive_max)
	landing_global_position =  Vector2(rand_range(10, _screen_dimension.x),_screen_dimension.y)
	global_position = initial_position
	_previous_global_position = initial_position
	_acceleration_current = acceleration_initial
	_init_healthComponents()
	_populate_waypoints_array()
	self.fuel_left = self.fuel_capacity



func _physics_process(delta: float) -> void:
	if _acceleration_current >= _acceleration_explosition: 
		self.reduce_health(self.health_damage_system.health)
#		TODO: make explosition
	
	if not is_drop_droid:
		if self.fuel_left <= 0 && not debug_is_fuel_infinite:
			_drop_droid()
			return
		elif self.is_droid_in_orbit:
			if not self.is_short_range_sensor_enabled:
				self.is_short_range_sensor_enabled = true
			_eat_idle_fuel()
			_check_and_return_to_refuel()
		elif self.is_droid_landed:
			self.is_all_equipment_enabled = false
			_goto_orbit()
			_eat_idle_fuel()
			_check_and_return_to_refuel()
		elif self.is_droid_in_platform:
			_refuel_droid()
		
		_eat_tractor_beam_fuel()
		
		if self.fuel_left > 0 && is_tractor_beam_enabled:
			_sync_tractor_beam_object_velocity()
	
	if self.is_in_movement:
		move_droid()
		if self.is_droid_going_to_refueling and self.is_all_equipment_enabled:
			self.is_all_equipment_enabled = false
			
	collides_check()
	
func move_droid()->void:
	#	calculate distance to eat fuel
	_recalculate_distances_and_eat_fuel()
	
	_velocity = Steering.follow(
		_velocity,
		global_position,
		target_global_position,
		_acceleration_current
	)
	_velocity = move_and_slide(_velocity)
	_sprite.rotation = _velocity.angle()
	
# recalculates already made distance and distance left
# before fuel will go out
func _recalculate_distances_and_eat_fuel()->void:
	var dx: float = global_position.x - _previous_global_position.x
	var dy: float = global_position.y - _previous_global_position.y
	var distance: float = round(sqrt(dx*dx + dy*dy))
	self.fuel_left -= distance * fuel_flying_consumption
	_total_flying_distance += distance
	_previous_global_position = global_position


# fall droid to the ground
func _drop_droid()->void:
	self.is_all_equipment_enabled = false
	randomize()
	target_global_position = Vector2(global_position.x, _screen_dimension.y)
	_acceleration_current = acceleration_initial
	tractor_beam_objects.clear()
	is_drop_droid = true

func _to_land_droid()->void:
	target_global_position = landing_global_position
	
func _eat_idle_fuel()-> void:
	self.fuel_left -= idle_fuel_consumption
	if self.is_short_range_sensor_enabled:
		self.fuel_left -= _sensorFuelConsumption

func _sync_tractor_beam_object_velocity()->void:
	for tractorObject in tractor_beam_objects:
		if tractorObject is Asteroid:
			tractorObject.max_speed = _acceleration_current
			tractorObject._velocity = _velocity

func _on_enable_tractor_beam(collisionObject: PhysicsBody2D) -> void:
	if collisionObject is Asteroid and is_instance_valid(collisionObject):
		self.is_tractor_beam_enabled = true
		collisionObject.target_global_position = landing_global_position
		tractor_beam_objects.push_back(collisionObject)
#		_tractorBeam.rotation = collisionObject._velocity.angle()
		_to_land_droid()

func _eat_tractor_beam_fuel():

	if self.is_tractor_beam_enabled:
		var totalAseroidMass := 0.0
		if tractor_beam_objects.size() <= 0:
			self.is_tractor_beam_enabled = false
			return
		for tractorObject in tractor_beam_objects:
			if tractorObject is Asteroid:
				var asteroidMass: float = tractorObject.get('mass')
				totalAseroidMass += asteroidMass

		self.fuel_left -= _tractorBeamFuelConsumption + TractorBeam.calculate_fuel_consumtion_for_mass(totalAseroidMass)
	
func _check_and_return_to_refuel() -> void:
# if we have an asteroid catched we cannot return 
# to base, as we need to land it first
	if self.fuel_left <= 0:
		return 
	elif not is_goto_platform_to_refuel_in_any_cases and self.is_tractor_beam_has_objects:
		return 
	elif self.is_droid_going_to_refueling:
		return 
	elif self.is_droid_in_platform:
		return 
	
#	calculate distance to platform and find out how many
#	fuel it will take
	var distanceToPlatform = global_position.distance_to(platform_global_position)
	var expectedFuelConsumption = distanceToPlatform * fuel_flying_consumption
	if self.fuel_left <= expectedFuelConsumption + fuel_reserve_limit:
#		reroute to platform
		self.is_all_equipment_enabled = false
		target_global_position = platform_global_position
		_acceleration_current = acceleration_initial

func _refuel_droid() -> void:
	if self.fuel_left >= fuel_capacity:
		self.fuel_left = fuel_capacity
		_goto_orbit()
	else:
		self.fuel_left += refueling_consumption

func _goto_orbit() -> void:
	target_global_position = orbit_global_position
	_acceleration_current = acceleration_initial

var is_mouse_hovered: bool = false

func _on_PrimitiveDroid_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick and is_mouse_hovered:
		self.is_droid_selected = not self.is_droid_selected
		return

func _input(event: InputEvent) -> void:
	var isRightClick = InputHelper.isRightClick(event)
	if isRightClick:
		self.is_droid_selected = false
		
func _on_PrimitiveDroid_mouse_entered() -> void:
	is_mouse_hovered = true


func _on_PrimitiveDroid_mouse_exited() -> void:
	is_mouse_hovered = false
