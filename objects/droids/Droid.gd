extends BaseDroidModule

class_name Droid

# platform for refueling 
var platform_global_position:= Vector2.ZERO
export var DISTANCE_PLATFORM_THRESHOLD: = 50.0
var is_droid_in_platform: bool = false setget , get_is_droid_in_platform
func get_is_droid_in_platform() -> bool:
	return global_position.distance_to(platform_global_position) <= DISTANCE_PLATFORM_THRESHOLD

func _init_healthComponents()->void:
	var resource_capacity = mass_capacity_kg/2
	var oxygenResource: = BaseResourceFactory.getOxygen(resource_capacity)
	var titaniumResource: = BaseResourceFactory.getTitanium(resource_capacity)
	health_damage_system.initSystem([oxygenResource,titaniumResource])


