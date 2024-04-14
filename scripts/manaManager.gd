extends CenterContainer

@export var maxMana = 10.0

@onready var manaLabel = $ManaLabel
@onready var manaContents = $ManaContents

var currentMana = 0.0

func _ready():
	currentMana = 0
	manaLabel.text = str(currentMana)
	updateManaDisplay()

func increaseMana(amount):
	if currentMana < maxMana:
		currentMana += amount
		updateManaDisplay()
	
func decreaseMana(amount):
	currentMana -= amount
	updateManaDisplay()
	
func updateManaDisplay():
	var contentsMatieral = manaContents.material as ShaderMaterial
	manaLabel.text = str(currentMana)
	contentsMatieral.set_shader_parameter("fillAmount", currentMana / maxMana)
