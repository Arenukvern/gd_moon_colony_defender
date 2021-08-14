extends Area2D

class_name TractorBeam

export var fuel_consumption: float = 2.0
const fuel_consumption_coeff: float = 10.0

static func calculate_fuel_consumtion_for_mass(mass: float)->float:
	return round(mass/fuel_consumption_coeff)