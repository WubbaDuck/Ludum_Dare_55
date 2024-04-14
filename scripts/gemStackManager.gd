extends VBoxContainer

@onready var stackedGemScene = preload("res://scenes/stacked_gem.tscn")

signal gem_gotten(gem)
signal gems_gone()

func _ready():
	# Cleanup the starting UI
	clearStack()

func clearStack():
	for n in get_children():
		remove_child(n)
		n.queue_free()
		
func loadCreatures(creatureNames : Array, shuffle : bool = false):
	if(shuffle):
		randomize()
		creatureNames.shuffle()
	
	for creatureName in creatureNames:
		var resourcePath = "res://creatures/" + creatureName + ".tres"
		var creatureResource = load(resourcePath)
		
		if creatureResource:
			createGem(creatureResource)
		else:
			print("Failed to load resource for creature: ", creatureName)
	
func createGem(creatureResource):
	var newGem = stackedGemScene.instantiate()
	newGem.setup(creatureResource)
	add_child(newGem)
	# TODO Maybe set a bit of random side-to-side positioning to give it some charm

func getGem():
	if get_child_count() > 0:
		var topGem = get_child(0)
	
		# TODO Animate Gem
		emit_signal("gem_gotten", topGem)
		remove_child(topGem)
		topGem.queue_free()
	else:
		emit_signal("gems_gone")
