extends TextureRect

class_name Gem

@onready var gm = get_node("/root/Game/GameManager")

var scaleAmount = 0.25
var startingPosition
var mouseEntered : bool = false

# Creature Info
var creatureType : String = "Nobody"
var cost = 0
var hp = 0
var creatureTexture : Texture
var creatureResource : Creature
var gemColor : Color

# Custom signals
signal gem_selected(gem)

func setup(thisResource : Creature):
	creatureType = thisResource.name
	cost = thisResource.cost
	hp = thisResource.hp
	creatureTexture = thisResource.creatureImage
	gemColor = thisResource.gemColor
	creatureResource = thisResource

	# Update visuals
	modulate = gemColor

func _ready():
	connect("mouse_entered", onMouseEntered)
	connect("mouse_exited", onMouseExited)
	mouse_filter = Control.MOUSE_FILTER_STOP # Ensure mouse events are captured

	gm.connectSignal(self, "gem_selected", gm.onGemSelected)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			onClicked()
		else:
			onRelease()

func onMouseEntered():
	z_index = 10
	
	# Set position and scale
	startingPosition = position
	scale = Vector2(scale.x + scaleAmount, scale.y + scaleAmount)
	position -= (size*scale - size)/2
	
	# Set color and other effects
	modulate = Color(modulate.r * 1.3, modulate.g * 1.3, modulate.b * 1.3)
	
	mouseEntered = true
	
func onMouseExited():
	z_index = 0
	
	# Set position and scale
	scale = Vector2(1,1)
	position = startingPosition
	
	# Set color and other effects
	modulate = gemColor
	
	mouseEntered = false

func onClicked():
	# TODO add particle effect here
	pass

func onRelease():
	if mouseEntered: # Only do onRelease things if mouse is still above
		emit_signal("gem_selected", self)
