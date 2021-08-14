extends MarginContainer

onready var root: =  $'.'
onready var maxAsteroidsFellLabel: =root.get_node('./VBoxContainer/MaxAsteroidsFell')
onready var maxDroidsFellLabel: =root.get_node('./VBoxContainer/MaxDroidsFell')
onready var uiState: = get_tree().get_root().get_node('/root/UIState')

func _ready() -> void:
	updateLabels()
	
func updateLabels()->void:
	if uiState == null: return
	maxAsteroidsFellLabel.text = "You survived against %s asteroids" % uiState.asteroidsQuantityHighscore
	maxDroidsFellLabel.text = "You lost droids %s times" % uiState.droidsLostHighscore
	