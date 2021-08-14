extends SpinBox

func _ready() -> void:
	set('value', AsteroidsState.asteroidStartMaxDistance)
	

func _on_AsteroidsStartMaxDistanceInput_value_changed(value: float) -> void:
	AsteroidsState.asteroidStartMaxDistance = value
