extends Button

var isPaused: bool setget set_isPaused, get_isPaused
func set_isPaused(isPaused: bool)->void:
	if isPaused:
		self.text = 'Resume'
	else:
		self.text = 'Pause'
		
	get_tree().paused = isPaused
	
func get_isPaused()-> bool:
	return get_tree().paused

func _on_PauseButton_button_up():
	self.isPaused = not self.isPaused
