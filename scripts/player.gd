extends Node

@onready var health = get_parent().get_node("UI").get_node("UI").get_node("PlayerHealth")
@onready var animPlayer = $PlayerBody/AnimationPlayer

func _ready():
	animPlayer.play("idle")

func increaseHealth(amount):
	health.increaseHealth(amount)
	
func decreaseHealth(amount):
	health.decreaseHealth(amount)

func animIdle():
	animPlayer.play("idle")
	
func animCast():
	animPlayer.play("cast")
