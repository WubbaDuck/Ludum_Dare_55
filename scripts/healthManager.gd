extends CenterContainer

@export var maxHealth = 10.0

@onready var healthContents = $HealthContents

var currentHealth = 0.0

func _ready():
	currentHealth = maxHealth
	
	var shaderMaterial = ShaderMaterial.new()
	shaderMaterial.shader = preload("res://shaders/healthBottle.gdshader")
	healthContents.material = shaderMaterial
	updateHealthDisplay()

func increaseHealth(amount):
	if currentHealth < maxHealth:
		currentHealth += amount
		updateHealthDisplay()
	
func decreaseHealth(amount):
	currentHealth -= amount
	updateHealthDisplay()
	
func updateHealthDisplay():
	var contentsMatieral = healthContents.material as ShaderMaterial
	contentsMatieral.set_shader_parameter("fillAmount", currentHealth / maxHealth)
