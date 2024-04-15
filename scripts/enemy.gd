extends Node

@onready var gm = get_parent().get_node("GameManager")
@onready var healthManager = get_parent().get_node("UI").get_node("UI").get_node("EnemyHealth")
@onready var animPlayer = $EnemyBody/AnimationPlayer

var maxHandSize = 4
var hand = []
var gemStack = []
var gemBag = []
var maxHealth = 10
var currentHealth = 0
var maxMana = 8
var currentMana = 3
var currentBeat = 0
var beatToAct = 0

func _ready():
	currentHealth = maxHealth
	healthManager.setMaxHealth(maxHealth)

func loadCreatures(creatureNames : Array, shuffle : bool = false):
	if(shuffle):
		randomize()
		creatureNames.shuffle()
	
	for creatureName in creatureNames:
		var resourcePath = "res://creatures/" + creatureName + ".tres"
		var creatureResource = load(resourcePath)
		
		if creatureResource:
			gemStack.append(creatureResource)
		else:
			print("Failed to load resource for creature: ", creatureName)

func getGem(): # Yes, this intentionally burns 1 tick when reloading the stack
	if hand.size() < maxHandSize:
		if not gemStack.is_empty():
			hand.append(gemStack.pop_front())
		else:
			gemStack = gemBag.duplicate(true)
			gemBag.clear() # TODO This might be a memory leak? Can GDScript memory leak?

func summon(creature : Creature):
	if not gm.enemySummonActive:
		gm.summon(gm.Summoner.ENEMY, gm.enemyCreatureSpawn, creature)
		
# Run Enemy AI
# Called every beat
func enemyTurn():
	var availableCreatures = []
	var sumonee = null
	
	if currentBeat == beatToAct:
		if gm.enemySummonActive: # If the enemy already has a creature out, return
			return
		
		# Popilate available creatures
		for dude in hand:
			if dude.cost < currentMana:
				availableCreatures.append(dude)
				
		if availableCreatures.is_empty(): # No available creatures
			return
			
		# Select best creature to summon
		sumonee = pickSummonee(availableCreatures)

		if sumonee != null:
			summon(sumonee)
			
			# remove from hand
			var index = hand.find(sumonee)		
			if index >= 0:
				hand.remove_at(index)
				
			# add to bag
			gemBag.append(sumonee)
	
	currentBeat += 1
	
				
# Very simplistic... just picks the highest cost/HP one available
func pickSummonee(dudes):
	var costs = []
	var topCost = 0
	
	for dude in dudes:
		costs.append(dude.cost)
	
	topCost = costs.max()
		
	for dude in dudes:
		if dude.cost == topCost:
			return dude
			
	return null

func setBeatToAct(beatsPerRound):
	beatToAct = randi() % beatsPerRound
	currentBeat = 0



################################################################################
# Resoruce Management
################################################################################
func increaseMana(amount):
	currentMana += amount
	
func decreaseMana(amount):
	currentMana -= amount
	
func increaseHealth(amount):
	currentHealth += amount
	healthManager.increaseHealth(amount)
	
func decreaseHealth(amount):
	currentHealth -= amount
	healthManager.decreaseHealth(amount)

func animIdle():
	animPlayer.play("idle")
	
func animCast():
	animPlayer.play("cast")
