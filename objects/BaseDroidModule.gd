extends KinematicBody2D

class_name BaseDroidModule

onready var projectRoot := get_tree().get_root()
onready var uiState := projectRoot.get_node("/root/UIState")
export var acceleration_for_landing: = 20.0
export var acceleration_initial: = 100.0
# current acceleration
var _acceleration_current: = 100.0
# current random acceleration when player can risk to run plasma
# but it can exlosure if the acceleration_current will be more than
# critical
var _acceleration_explosition: = 100.0
# distance between target position and current position 
# droid should stop

# !!! must be filled with base resourse components !!!
onready var health_damage_system: HealthDamageSystem = HealthDamageSystem.new()
func reduce_health(points: float) -> void:
	health_damage_system.add_random_damage(points)
	if health_damage_system.health <= 0:
		uiState.addDroidFellToHighscore()
		self.are_all_waypoints_shown = false
		UIState.isWaypointsManagerOpen = false
		DroidsState.remove_droid_from_state(self)
		DroidsState.notifyDroidsOnAirUpdated()
		queue_free()

func collides_check()->void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if 'health_damage_system' in collision.collider and 'mass_kg' in collision.collider:
			collision.collider.reduce_health(self.mass_kg * 0.3)
			self.reduce_health(collision.collider.mass_kg * 0.1)

export var mass_capacity_kg: = 10.0
var mass_kg: float =0.0 setget , get_mass_kg
func get_mass_kg()->float:
	return health_damage_system.mass_kg

export var DISTANCE_THRESHOLD: = 3.0
var target_global_position: = Vector2.ZERO
var _previous_global_position: = Vector2.ZERO
# start position, usually needs to be equal platform position
var initial_position: = Vector2.ZERO
var _velocity:= Vector2.ZERO
export var fuel_capacity: = 15000.0
export var fuel_left: = 15000.0 setget set_fuel_left, get_fuel_left
func set_fuel_left(newValue: float)->void:
	health_damage_system.oxygen.mass_kg = newValue
	
func get_fuel_left()->float:
	return health_damage_system.oxygen.mass_kg

export var refueling_consumption: = 100.0
export var debug_is_fuel_infinite: = false
var is_in_movement := false setget ,get_is_in_movement

func get_is_in_movement()->bool:
	return global_position.distance_to(target_global_position) > DISTANCE_THRESHOLD

var is_droid_in_target := false setget , get_is_droid_in_target
func get_is_droid_in_target()->bool:
	return not self.is_in_movement
	
const WaypointGd: = preload('res://objects/droids/Waypoint.gd') 
onready var platformWaypoint: = WaypointGd.new()

export var are_all_waypoints_shown: bool = false setget set_are_all_waypoints_shown
func set_are_all_waypoints_shown(isEnable: bool)->void:
	are_all_waypoints_shown= isEnable
	
	clear_all_waypoints()
	if isEnable:
		for waypoint in self._waypoints_array:
			var selection: Node = waypoint.waypoint_scene.instance()
			selection.global_position = waypoint.global_position
			projectRoot.add_child(selection)
			_waypoints_selections_array.push_back(selection)
			
func clear_all_waypoints():
	for selection in self._waypoints_selections_array:
		if is_instance_valid(selection):
			selection.queue_free()
	_waypoints_selections_array.clear()
var _waypoints_array: Array = []
var _waypoints_selections_array: Array = []

