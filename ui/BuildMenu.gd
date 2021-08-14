extends Control

onready var uiState: = $"/root/UIState"
onready var droidsState: = $"/root/DroidsState"
const distanceToMoon:float = -100.0
var _newBuildingScene
onready var buidlingsFactory: BuildingFactory = BuildingFactory.new()
onready var _screen_dimension = OS.get_window_size()
func _on_SpaceModule_button_up():
	uiState._is_building_selector_active = true
	_newBuildingScene = buidlingsFactory.baseModule
	
func _on_DroidFactory_button_up():
	uiState._is_building_selector_active = true
	_newBuildingScene = buidlingsFactory.primitiveDroidPlatform

func _input(event):
	if not uiState._is_building_selector_active: return
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick :
		uiState._is_building_selector_active = false
		_place_building(get_global_mouse_position().x)
		return 
	var isRightClick = InputHelper.isRightClick(event)
	if isRightClick:
		uiState._is_building_selector_active = false
		
func _place_building(x: float)->void:
#	add func
	var newBuidling = _newBuildingScene.instance()
	newBuidling.global_position = Vector2(x,distanceToMoon)
	newBuidling.target_global_position = Vector2(x,_screen_dimension.y)
	if is_instance_valid(newBuidling):
		droidsState.addCustomDroid(newBuidling)
