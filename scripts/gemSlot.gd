extends Node

@onready var slot = $GemSlotMargin
var gemHeld : bool = false

func addGem(gem):
	if !gemHeld:
		slot.add_child(gem)
		gemHeld = true
	
func removeGem():
	if gemHeld:
		slot.remove_child(slot.get_child(0))
		gemHeld = false

func hasGem():
	return gemHeld

func isThisGem(gem):
	if gemHeld and slot.get_child(0) == gem:
		return true
	else:
		return false
