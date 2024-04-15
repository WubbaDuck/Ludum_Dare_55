extends Node

@onready var slot = $GemSlotMargin
var gemHeld : bool = false
var newGem = null

#func gemTweenFinished():
	#get_tree().current_scene.get_node("UI").get_node("UI").remove_child(newGem)
	#slot.add_child(newGem)
	#gemHeld = true

func addGem(gem):
	if !gemHeld:
		newGem = gem
		slot.add_child(newGem)
		gemHeld = true
		#get_tree().current_scene.get_node("UI").get_node("UI").add_child(newGem)
		#newGem.global_position.x = 0
		#var tween = create_tween()
		#tween.tween_property(gem, "global_position", self.global_position, 0.2)
		#tween.tween_callback(gemTweenFinished)
		

	
func removeGem():
	if gemHeld:
		var child = slot.get_child(0)
		var prevPosition = child.get_global_position()
		slot.remove_child(child)
		get_tree().current_scene.get_node("UI").get_node("UI").add_child(child)
		
		#var localPos = get_tree().current_scene.get_node("UI").get_node("UI").to_local(prevPosition)
		child.position = prevPosition
		
		gemHeld = false

func hasGem():
	return gemHeld

func isThisGem(gem):
	if gemHeld and slot.get_child(0) == gem:
		return true
	else:
		return false
