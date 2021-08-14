extends Button
onready var uiState: = $"/root/UIState"

func _on_CloseButton_button_up() -> void:
	uiState.isDebugMenuOpen = false
