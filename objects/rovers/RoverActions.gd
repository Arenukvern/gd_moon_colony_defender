extends Control

class_name RoverActions

signal rover_actions_close
const signal_name_rover_actions_close: = 'rover_actions_close'
const signal_func_name_close_rover_actions: = "_on_%s" % signal_name_rover_actions_close

signal rover_actions_load
const signal_name_rover_actions_load: = 'rover_actions_load'
const signal_func_name_rover_actions_load: = "_on_%s" % signal_name_rover_actions_load

signal rover_actions_unload
const signal_name_rover_actions_unload: = 'rover_actions_unload'
const signal_func_name_rover_actions_unload: = "_on_%s" % signal_name_rover_actions_unload

signal rover_actions_to_base
const signal_name_rover_actions_to_base: = 'rover_actions_to_base'
const signal_func_name_rover_actions_to_base: = "_on_%s" % signal_name_rover_actions_to_base

func _on_Load_button_up() -> void:
	emit_signal(signal_name_rover_actions_load)

func _on_Base_button_up() -> void:
	emit_signal(signal_name_rover_actions_to_base)
	close_actions()

func _unhandled_input(event: InputEvent) -> void:
	var isRightClick: = InputHelper.isRightClick(event)
	if isRightClick:
		close_actions()
		queue_free()
		
func close_actions()->void:
	emit_signal(signal_name_rover_actions_close)

func _on_Unload_button_up():
	emit_signal(signal_name_rover_actions_unload)

var isHovered: bool = false setget set_isHovered
func set_isHovered(_isHovered: bool)->void:
	isHovered = _isHovered

func _on_PanelContainer_mouse_entered():
	self.isHovered = true
func _on_PanelContainer_mouse_exited():
	self.isHovered = false
func _on_Load_mouse_entered():
	self.isHovered = true
func _on_Load_mouse_exited():
	self.isHovered = false
func _on_Unload_mouse_entered():
	self.isHovered = true
func _on_Unload_mouse_exited():
	self.isHovered = false
func _on_Base_mouse_entered():
	self.isHovered = true
func _on_Base_mouse_exited():
	self.isHovered = false
