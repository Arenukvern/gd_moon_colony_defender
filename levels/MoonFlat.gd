extends Node2D
onready var uiDebug := $'./MenuLayer/UIDebug'
	
var is_ui_visible : bool = false setget set_is_ui_visible
func set_is_ui_visible(isVisible:bool)->void:
	is_ui_visible = isVisible
	if is_instance_valid(uiDebug):
		uiDebug.visible = isVisible
	else: 
		var uiDebugTemp := $'./MenuLayer/UIDebug'
		uiDebugTemp.visible = isVisible
		
