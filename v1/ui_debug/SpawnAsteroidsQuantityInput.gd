extends SpinBox

func _ready() -> void:
	set('value', AsteroidsState.asteroidSpawnQuantity)
	
func _on_SpawnAsteroidsQuantityInput_value_changed(value: float) -> void:
	AsteroidsState.asteroidSpawnQuantity = value
