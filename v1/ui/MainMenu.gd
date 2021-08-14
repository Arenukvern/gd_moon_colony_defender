extends Control

class_name MainMenu

onready var uiState: = get_tree().get_root().get_node("/root/UIState")

func _on_ContinueButton_button_up() -> void:
	uiState.closeMainMenu()
	
func _on_ExitButton_button_up() -> void:
	get_tree().quit()

onready var windowDialog: = $'./CanvasLayer/WindowDialog'
var is_highscore_window_active: bool = false setget set_is_highscore_window_active
const HighscoreContentScene: = preload('res://ui/MaxHighscoreContent.tscn')
var _highscoreContent
func set_is_highscore_window_active(isEnable: bool):
	is_highscore_window_active = isEnable
	if isEnable:
		if not is_instance_valid(_highscoreContent):
			_highscoreContent = HighscoreContentScene.instance()
			windowDialog.add_child(_highscoreContent)
	else:
		print(is_instance_valid(_highscoreContent))
		if is_instance_valid(_highscoreContent):
			_highscoreContent.queue_free()

func _on_HighscoreButton_button_up() -> void:
	windowDialog.visible = true
	self.is_highscore_window_active = true
	self.is_help_window_active = false
	self.is_plot_window_active = false
	
var is_help_window_active: bool = false setget set_is_help_window_active
const HelpContentScene: = preload('res://ui/HelpContent.tscn')
var _helpContent
func set_is_help_window_active(isEnable: bool):
	is_help_window_active = isEnable
	if isEnable:
		if not is_instance_valid(_helpContent):
			_helpContent = HelpContentScene.instance()
			windowDialog.add_child(_helpContent)
	else:
		if is_instance_valid(_helpContent):
			_helpContent.queue_free()

func _on_HelpButton_button_up() -> void:
	windowDialog.visible = true
	self.is_highscore_window_active = false
	self.is_help_window_active = true
	self.is_plot_window_active = false

var is_plot_window_active: bool = false setget set_is_plot_window_active
const PlotContentScene: = preload('res://ui/PlotContent.tscn')
var _plotContent
func set_is_plot_window_active(isEnable: bool):
	is_help_window_active = isEnable
	if isEnable:
		if not is_instance_valid(_plotContent):
			_plotContent = PlotContentScene.instance()
			windowDialog.add_child(_plotContent)
	else:
		if is_instance_valid(_plotContent):
			_plotContent.queue_free()
func _on_Plot_button_up() -> void:
	windowDialog.visible = true
	self.is_highscore_window_active = false
	self.is_help_window_active = false
	self.is_plot_window_active = true
