extends TextureRect

class_name StackedGem

# Creature Info
var creatureResource : Creature
var gemColor : Color

func setup(thisResource : Creature):
	gemColor = thisResource.gemColor
	creatureResource = thisResource

	# Update visuals
	modulate = gemColor
