extends BaseDroidModule

var debug_is_selection_disabled: bool = true

onready var root: = $'.'

const ModuleSelectionScene: = preload('res://objects/lunar_base/ModuleSelection.tscn')
var _module_selection: Area2D
var is_module_selected: bool = false setget set_is_module_selected
func set_is_module_selected(isSelect: bool)->void:
	is_module_selected = isSelect
	if isSelect:
		_module_selection = ModuleSelectionScene.instance()
		root.add_child(_module_selection)
	elif not isSelect and is_instance_valid(_module_selection):
		_module_selection.queue_free()

func _on_BaseModule_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if debug_is_selection_disabled: return
	var isLeftClick = InputHelper.isLeftClick(event)
	if isLeftClick:
		self.is_module_selected = not self.is_module_selected

func _init_healthComponents()->void:
	var oxygenResource: = BaseResourceFactory.getOxygen(mass_kg)
	var titaniumResource: = BaseResourceFactory.getTitanium(mass_kg)
	var waterIceResource: = BaseResourceFactory.getWaterIce(mass_kg)
	var silicaResource: = BaseResourceFactory.getSilica(mass_kg)
	var glassResource: = BaseResourceFactory.getGlass(mass_kg)
	var components = [
		oxygenResource,
		titaniumResource,
		silicaResource,
		waterIceResource,
		glassResource
	]
	health_damage_system.initSystem(components)

func _ready() -> void:
	mass_kg = 200.0
	_init_healthComponents()
