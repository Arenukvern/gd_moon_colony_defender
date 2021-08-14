extends SpinBox

func _ready() -> void:
	set('value', AsteroidsState.seconds_until_spawn)
	

func _on_AsteroidsSpawnTimeInput_value_changed(value: float) -> void:
	AsteroidsState.seconds_until_spawn = value
