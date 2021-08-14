extends Panel

signal waypoint_selected
const signal_name_waypoint_selected: = 'waypoint_selected'
const signal_func_name_waypoint_selected: = "_on_%s" % signal_name_waypoint_selected
signal close_waypoints_selection
const signal_name_close_waypoints_selection: = 'close_waypoints_selection'
const signal_func_name_close_waypoints_selection: = "_on_%s" % signal_name_close_waypoints_selection

signal reboot_droids_power
const signal_name_reboot_droids_power: = 'reboot_droids_power'
const signal_func_name_reboot_droids_power: = "_on_%s" % signal_name_reboot_droids_power

class_name WaypointsManager

onready var _orbitCheckBtn = $'./MarginContainer/VBoxContainer/Orbit/OrbitCheckBtn'
onready var _platformCheckBtn = $'./MarginContainer/VBoxContainer/Platform/PlatformCheckBtn'
onready var _landingCheckBtn = $'./MarginContainer/VBoxContainer/Landing/LandingCheckBtn'

var selectedPositionType: int = WaypointFactory.PositionType.ORBIT setget set_selectedPositionType

func _ready() -> void:
	self.selectedPositionType = WaypointFactory.PositionType.ORBIT
	
func set_selectedPositionType(positionType: int)->void:
	selectedPositionType = positionType
	_orbitCheckBtn.pressed = false
	_platformCheckBtn.pressed = false
	_landingCheckBtn.pressed = false
	match positionType:
		WaypointFactory.PositionType.ORBIT:
			_orbitCheckBtn.pressed = true
		WaypointFactory.PositionType.PLATFORM:
			_platformCheckBtn.pressed = true
		WaypointFactory.PositionType.LANDING:
			_landingCheckBtn.pressed = true
	
	
func _on_Orbit_gui_input(event: InputEvent) -> void:
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick:
		self.selectedPositionType = WaypointFactory.PositionType.ORBIT

func _on_Platform_gui_input(event: InputEvent) -> void:
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick:
		self.selectedPositionType = WaypointFactory.PositionType.PLATFORM

func _on_Landing_gui_input(event: InputEvent) -> void:
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick:
		self.selectedPositionType = WaypointFactory.PositionType.LANDING

func _unhandled_input(event: InputEvent) -> void:
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick:
		send_new_waypoint_position()

	
func send_new_waypoint_position()->void:
	if not is_mouse_hovered:
		emit_signal(
			signal_name_waypoint_selected, 
			{ 'position': get_global_mouse_position(), 'position_type': selectedPositionType }
		)

var is_mouse_hovered: bool = false

func _on_WaypointsManager_mouse_entered() -> void:

	is_mouse_hovered = true

func _on_WaypointsManager_mouse_exited() -> void:
	is_mouse_hovered = false

func _on_CloseBtn_button_up() -> void:
	closeSelected()

func closeSelected()->void:
	emit_signal(signal_name_close_waypoints_selection)

func _on_RebootPower_button_up() -> void:
	emit_signal(signal_name_reboot_droids_power)


func _on_PlatformCheckBtn_button_up():
	self.selectedPositionType = WaypointFactory.PositionType.PLATFORM

func _on_OrbitCheckBtn_button_up():
	self.selectedPositionType = WaypointFactory.PositionType.ORBIT

func _on_LandingCheckBtn_button_up():
	self.selectedPositionType = WaypointFactory.PositionType.LANDING
