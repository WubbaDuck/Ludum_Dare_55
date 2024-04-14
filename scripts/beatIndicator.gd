extends PanelContainer

@export var beatOnImage : Texture2D
@export var beatOffImage : Texture2D

@onready var beatContainer = $BeatIndicatorHContainer
@onready var beatIcon = preload("res://scenes/beat_indicator_icon.tscn")

var beatsPerRound = 0
var currentBeat = 0

func init(beatCount):
	beatsPerRound = beatCount
	
	# Clear placeholders
	for child in beatContainer.get_children():
		beatContainer.remove_child(child)
		child.queue_free()

	for i in beatsPerRound:
		var newBeat = beatIcon.instantiate()
		newBeat.texture = beatOnImage
		beatContainer.add_child(newBeat)

func incrementBeat():
	if currentBeat <= beatsPerRound:
		beatContainer.get_child(currentBeat).texture = beatOffImage
		currentBeat += 1	

func resetBeat():
	for child in beatContainer.get_children():
		child.texture = beatOnImage
	
	currentBeat = 0
