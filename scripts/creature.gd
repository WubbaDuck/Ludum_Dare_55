extends Resource
class_name Creature

@export var name: String = "Nobody"
@export var cost = 1
@export var hp = 1
@export var creatureImage = preload("res://assets/images/default_creature.jpg")
@export var gemColor = Color(1, 1, 1)
@export var creatureBody : PackedScene
var gemImage = preload("res://icon.svg")
