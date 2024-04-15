extends Node

@export var maxGemsInHand = 4
@onready var gemInHand = preload("res://scenes/gem_in_hand.tscn")
@onready var gemSlot = preload("res://scenes/gem_slot.tscn")
@onready var gemHandContainer = $GemHandHContainer
@onready var gemStack = get_parent().get_node("GemStackPanel/GemStack")
@onready var audioPlayer = get_tree().current_scene.get_node("AudioPlayer")

var currentGemsInHand = 0

func _ready():
	gemStack.connect("gem_gotten", addGem)
	handSetup();

func handSetup():
	for n in gemHandContainer.get_children():
		gemHandContainer.remove_child(n)
		n.queue_free()
		
	for i in maxGemsInHand:
		var newSlot = gemSlot.instantiate()
		gemHandContainer.add_child(newSlot)
	
func addGem(stackedGem):
	if stackedGem && getEmptySlotCount() > 0:		
		for slot in gemHandContainer.get_children():
			if !slot.hasGem():
				var newGem = gemInHand.instantiate()
				newGem.setup(stackedGem.creatureResource)
				
				# Set image and cost for this Gem
				newGem.get_child(0).get_child(0).get_node("CreatureImage").texture = newGem.creatureTexture
				newGem.get_child(0).get_child(0).get_node("CostLabel").text = str(newGem.cost)
								
				slot.addGem(newGem)
				currentGemsInHand += 1
				audioPlayer.playSFX("newGem")
				break

func removeGem(gem):
	for slot in gemHandContainer.get_children():
		if slot.isThisGem(gem):
			slot.removeGem()
			currentGemsInHand -= 1

func getEmptySlotCount():
	return (maxGemsInHand - currentGemsInHand)
