extends Node2D

@onready var gm = get_node("/root/Game/GameManager")

var creatureName = "Nobody"
var cost = 1
var hp = 1
var gemColor = Color(1, 1, 1)

signal creature_died(creature)

func _ready():
	gm.connectSignal(self, "creature_died", gm.onCreatureDied)

func init(source : Creature):
	cost = source.cost
	hp = source.hp

func decreaseHealth(amount):
	hp -= amount
	checkDead()
	
func increaseHealth(amount):
	hp += amount
	checkDead()
	
func checkDead():
	if hp <= 0:
		emit_signal("creature_died", self)
