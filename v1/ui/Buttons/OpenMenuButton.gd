extends Button

onready var uiState: = get_tree().get_root().get_node("UIState")

func _on_OpenMenuButton_button_up() -> void:
	uiState.openMainMenu()
