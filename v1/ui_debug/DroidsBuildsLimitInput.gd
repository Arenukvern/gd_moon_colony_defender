extends SpinBox


func _ready() -> void:
	set('value', DroidsState.maxDroidsQuantity)
	

func _on_DroidsBuildsLimitInput_value_changed(value: float) -> void:
	DroidsState.maxDroidsQuantity = value
	DroidsState.notifyDroidsOnAirUpdated()
