extends Node

class_name InputHelper

static func isLeftClick(event: InputEvent)-> bool:
	var isLeftClick = (event is InputEventMouseButton and event.button_index == BUTTON_LEFT)  or event is InputEventScreenTouch 
	return isLeftClick && event.is_pressed()
	
static func isRightClick(event: InputEvent)-> bool:
	var isLeftClick = (event is InputEventMouseButton and event.button_index == BUTTON_RIGHT)  or event is InputEventScreenTouch 
	return isLeftClick && event.is_pressed()
