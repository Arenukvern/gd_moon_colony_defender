extends Control

const MENU_OVERLAY: String = 'MenuOverlay'

onready var uiState: = $"/root/UIState"
onready var droidsState: = $"/root/DroidsState"

onready var rootNode: = $'.'
onready var buttonsNode: = $'./ButtonsContainer'
onready var droidsCurrentHighscore: Label= buttonsNode.get_node('DroidsLostCurrentHighscore')
onready var asteroidsFellCurrentHighscore:Label = buttonsNode.get_node('AsteroidsFellCurrentHighscore')
onready var droidsLimitLabel: Label = buttonsNode.get_node('DroidsLimit')

const overlayScene: = preload("res://ui_debug/UIDebugMenuOverlay.tscn")

func _ready() -> void:
	uiState.connect(
		uiState.signal_name_debug_menu_state_updated, 
		self, 
		uiState.signal_func_name_debug_menu_state_updated
	)
	uiState.connect(
		uiState.signal_name_highscore_updated, 
		self, 
		uiState.signal_func_name_highscore_updated
	)
	_on_highscore_updated()
	droidsState.connect(
		droidsState.signal_name_droids_on_air_updated,
		self,
		droidsState.signal_func_name_droids_on_air_updated
	)
	_on_droids_on_air_updated()

func _on_droids_on_air_updated()->void:
	droidsLimitLabel.text = 'Droids on air: %s / %s' % [droidsState.currentDroidsQuantity, droidsState.maxDroidsQuantity]
		
func _on_highscore_updated()->void:
	droidsCurrentHighscore.text = 'Droids lost: %s' % uiState.droidsLostHighscoreCurrent
	asteroidsFellCurrentHighscore.text = 'Asteroids fell: %s' % uiState.asteroidsQuantityHighscoreCurrent

func _on_debug_menu_state_updated(enabled: bool) -> void:
	if enabled:	
		var overlayInstance: = overlayScene.instance()
		overlayInstance.set_name(MENU_OVERLAY)
		rootNode.add_child(overlayInstance)
		buttonsNode.visible = false
	else:
		if rootNode.has_node(MENU_OVERLAY) :
			get_node(MENU_OVERLAY).queue_free()
		buttonsNode.visible = true

