extends Node

signal debug_menu_state_updated(enabled)
const signal_name_debug_menu_state_updated: = 'debug_menu_state_updated'
const signal_func_name_debug_menu_state_updated: = "_on_%s" % signal_name_debug_menu_state_updated

signal highscore_updated
const signal_name_highscore_updated: = 'highscore_updated'
const signal_func_name_highscore_updated: = "_on_%s" % signal_name_highscore_updated

onready var saveLoadHelper = load('res://helpers/SaveLoadHelper.gd').new()

func getSave():
	var save_dict = {
		'droidsLostHighscore': droidsLostHighscore,
		'asteroidsQuantityHighscore':asteroidsQuantityHighscore
	}
	return save_dict
	
onready var root: = get_tree().get_root()
onready var me: = $'.'
onready var scenesRoot: = root.get_node('ScenesRoot')
var current_scene = null

# HIGHSCORE
var asteroidsQuantityHighscoreCurrent: float = 0.0 setget set_asteroidsQuantityHighscoreCurrent
func set_asteroidsQuantityHighscoreCurrent(highscore: float)->void:
	asteroidsQuantityHighscoreCurrent = highscore
	emitHighscoreUpdated()

func emitHighscoreUpdated()->void:
	compareHighscoresAndSetNew()
	saveLoadHelper.saveUiState(self)

func addAsteroidToHighscore()->void:
	self.asteroidsQuantityHighscoreCurrent += 1

var asteroidsQuantityHighscore: float= 0.0
var droidsLostHighscore: float = 0.0
var droidsLostHighscoreCurrent: float = 0.0 setget set_droidsLostHighscoreCurrent
func set_droidsLostHighscoreCurrent(highscore: float)->void:
	droidsLostHighscoreCurrent = highscore
	emitHighscoreUpdated()
func addDroidFellToHighscore()->void:
	self.droidsLostHighscoreCurrent += 1
func compareHighscoresAndSetNew()->void:
	if self.droidsLostHighscoreCurrent > droidsLostHighscore:
		droidsLostHighscore = self.droidsLostHighscoreCurrent
	if self.asteroidsQuantityHighscoreCurrent > asteroidsQuantityHighscore:
		asteroidsQuantityHighscore = self.asteroidsQuantityHighscoreCurrent
	emit_signal(signal_name_highscore_updated)

func resetCurrentHighscore():
	self.droidsLostHighscoreCurrent = 0
	self.asteroidsQuantityHighscoreCurrent = 0

#temporary level management
const MainMenuScene: = preload('res://ui/MainMenu.tscn')
var _mainMenu: MainMenu 

onready var _moonFlat: = scenesRoot.get_node('MoonFlat')

func _ready():
	saveLoadHelper.loadUiState(self)
	_mainMenu = scenesRoot.get_node('MainMenu')
	current_scene= _moonFlat
	get_tree().set_current_scene(_moonFlat)
	openMainMenu()
	compareHighscoresAndSetNew()

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	scenesRoot.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)


onready var waypointsLayer: = root.get_node("/root/WaypointsState")
onready var asteroidsState: = root.get_node("/root/AsteroidsState")
onready var baseResourceState: = root.get_node("/root/BaseResourcesState")
onready var droidsState: = root.get_node("/root/DroidsState")

const WaypointsManagerScene: = preload('res://ui/WaypointsManager.tscn')
var waypointManager: Node

var isDebugMenuOpen:= false setget set_isDebugMenuOpen

func set_isDebugMenuOpen(value: bool) -> void:
	isDebugMenuOpen = value
	emit_signal(signal_name_debug_menu_state_updated,value)

var isWaypointsManagerOpen: bool = false setget set_isWaypointsManagerOpen

func set_isWaypointsManagerOpen(isEnable: bool)->void:
	isWaypointsManagerOpen = isEnable
	if isEnable :
		if is_instance_valid(waypointManager) and waypointManager is WaypointsManager:
			waypointManager.closeSelected()
			waypointManager.queue_free()
			
		waypointManager = WaypointsManagerScene.instance()
		waypointManager.connect(
			waypointManager.signal_name_close_waypoints_selection,
			self,
			waypointManager.signal_func_name_close_waypoints_selection
		)
		waypointsLayer.add_child(waypointManager)
	elif not isEnable and is_instance_valid(waypointManager):
		waypointManager.queue_free()

func _on_close_waypoints_selection()->void:
	self.isWaypointsManagerOpen = false

func openMainMenu()->void:
	current_scene.is_ui_visible = false
	get_tree().paused = true
	current_scene.visible = false
	if not is_instance_valid(_mainMenu) or not _mainMenu is MainMenu:
		_mainMenu = MainMenuScene.instance()
		scenesRoot.add_child(_mainMenu)	
	
func closeMainMenu()->void:
	if is_instance_valid(_mainMenu):
		_mainMenu.queue_free()
	get_tree().paused = false
	current_scene.visible = true
	current_scene.is_ui_visible = true
	
	
func restartgame()->void:
	var arr = [baseResourceState,asteroidsState, waypointsLayer]
	for stateNode in arr:
		for child in stateNode.get_children():
			child.queue_free()
	droidsState.clearChildren()
	
	closeMainMenu()
	resetCurrentHighscore()
	goto_scene('res://levels/MoonFlat.tscn')

const _placeSelectorScene: = preload("res://objects/selectors/PlaceSelector.tscn")
var _placeSelector: PlaceSelector

var _is_building_selector_active: bool = false setget set_is_building_selector_active
func set_is_building_selector_active(isActive:bool)->void:
	_is_building_selector_active = isActive
	if isActive and not is_instance_valid(_placeSelector):
		_placeSelector = _placeSelectorScene.instance()
		me.add_child(_placeSelector)
	elif is_instance_valid(_placeSelector):
		_placeSelector.queue_free()
