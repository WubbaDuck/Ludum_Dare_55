extends Node

@onready var health = get_parent().get_node("UI").get_node("UI").get_node("PlayerHealth")

func increaseHealth(amount):
	health.increaseHealth(amount)
	
func decreaseHealth(amount):
	health.decreaseHealth(amount)
