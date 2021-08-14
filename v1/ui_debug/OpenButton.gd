extends Button
onready var uiState: = $"/root/UIState"

func _on_OpenButton_button_up() -> void:
	uiState.isDebugMenuOpen = true
