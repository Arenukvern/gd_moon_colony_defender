tool
extends Button

export (String, FILE) var next_scene_path: ='' 
onready var uiState: = get_tree().get_root().get_node("/root/UIState")

func _on_MainMenuButton_button_up() -> void:
	uiState.restartgame()

func _get_configuration_warning() -> String:
	return 'Next scene path must be set!' if next_scene_path == '' else ''
