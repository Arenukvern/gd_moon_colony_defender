extends Button

onready var root: Node = $'.'

func _on_SpawnAsteroids_button_up() -> void:
	AsteroidsState.add_asteroid()
