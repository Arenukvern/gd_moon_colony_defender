extends Area2D

signal enable_tractor_beam

class_name ShortRangeSensor

const signal_name_enable_tractor_beam: = 'enable_tractor_beam'
const signal_func_name_enable_tractor_beam: = "_on_%s" % signal_name_enable_tractor_beam

export var fuel_consumption: float = 2.0

func _on_ShortRangeSensor_body_entered(body: PhysicsBody2D) -> void:
	_detect_colision(body)

func _detect_colision(body: PhysicsBody2D)->void:
	if not is_instance_valid(body) or body == null: 
		return
	var isCollisionObjectAsteroid: = body.name.to_lower().find('asteroid') > 0
	if isCollisionObjectAsteroid:
		_enable_tractor_beam(body)
		
func _enable_tractor_beam(body: PhysicsBody2D)->void:
	emit_signal(signal_name_enable_tractor_beam,body)