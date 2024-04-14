extends Node2D

@onready var ui = get_parent().get_node("UI").get_node("UI")
@onready var mana = ui.get_node("Mana")
@onready var playerHealth = ui.get_node("PlayerHealth")
@onready var enemyHealth = ui.get_node("EnemyHealth")
@onready var gemStack = ui.get_node("GemStackPanel/GemStack")
@onready var gemHand = ui.get_node("GemHandPanel")
@onready var beatIndicator = ui.get_node("BeatIndicatorPanel")
@onready var gemBag = ui.get_node("GemBag")
@onready var player = get_parent().get_node("Player")
@onready var enemy = get_parent().get_node("Enemy")

@export var playerCreatureSpawn : Node2D
@export var enemyCreatureSpawn : Node2D
var playerCreature : Node2D = null
var enemyCreature : Node2D = null

enum Summoner {
	PLAYER,
	ENEMY
}

var bpm = 120.0
var beatsPerRound = 5
var beatMultiplier = 4
var accruedTime = 0

var gameStarted = false
var playerSummonActive = false
var enemySummonActive = false
var gemsInStack = ["squirrel", "porcupine", "squirrel", "porcupine", "squirrel", "porcupine", "squirrel", "porcupine", "squirrel", "porcupine"]
var enemyGemsInStack = ["squirrel", "porcupine", "squirrel", "porcupine", "squirrel", "squirrel", "squirrel", "squirrel", "squirrel", "squirrel"]

func _ready():
	gemStack.loadCreatures(gemsInStack, true)
	beatIndicator.init(beatsPerRound)
	gemStack.connect("gems_gone", resetGemStack)
	
	enemy.loadCreatures(enemyGemsInStack, true)
	enemy.setBeatToAct(beatsPerRound)

func _process(delta):
	accruedTime += delta
	
	# Handle quick key
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# TODO Handle Win/Lose State
	# TODO Check Healths Here
	
	# On the beat do things
	if accruedTime >= (60.0 / bpm) * beatMultiplier: # TODO sync this to the music
		accruedTime = 0
		
		# Gain Mana
		if mana.currentMana >= mana.maxMana:
			playerHealth.decreaseHealth(0.25) # TODO Evaluate this. It doesn't feel quite right
			enemy.decreaseHealth(0.25)
		else:
			playerHealth.increaseHealth(0.25)
			enemy.increaseHealth(0.25)
			mana.increaseMana(1);
			enemy.increaseMana(1);
		
		# Get a new gem into hand
		if(gemHand.getEmptySlotCount() > 0):
			gemStack.getGem() # TODO Animate this	
			
		enemy.getGem()

		# Do enemy things
		enemy.enemyTurn()

		# TODO Animate the gem stack trying to bounce out and fill the hand

		# Decrease or reset the beat indicator
		if beatIndicator.currentBeat >= beatsPerRound:
			beatIndicator.resetBeat()
			enemy.setBeatToAct(beatsPerRound)
			
			doFight()
		else:
			beatIndicator.incrementBeat()

################################################################################t
# Signal Callbacks	
################################################################################	
func onGemSelected(gem):
	if mana.currentMana >= gem.cost and not playerSummonActive: # Check summoning cost
		mana.decreaseMana(gem.cost)
		gemHand.removeGem(gem)
		gemBag.addToBag(gem)
		
		# Player Summon
		summon(Summoner.PLAYER, playerCreatureSpawn, gem.creatureResource)
	else:
		# TODO Play sound
		pass

func onCreatureDied(creature):
	for child in player.get_children():
		if child == creature:
			player.remove_child(child)
			child.queue_free()
			playerSummonActive = false
			playerCreature = null
			return
	for child in enemy.get_children():
		if child == creature:
			enemy.remove_child(child)
			child.queue_free()
			enemySummonActive = false
			enemyCreature = null
			return

func connectSignal(source : Node, signalName : String, targetFunction):
	source.connect(signalName, targetFunction)

func resetGemStack(): # Recycle
		gemsInStack.clear()
		
		for gem in gemBag.gems:
			gemsInStack.append(gem.creatureType)
			
		gemBag.emptyBag()
		gemStack.clearStack()
		gemStack.loadCreatures(gemsInStack, true)

# TODO Animate Summoning
func summon(summoner : Summoner, location : Node2D, creature : Creature):
	var summonee = creature.creatureBody.instantiate()
	summonee.init(creature)
	
	if summoner == Summoner.PLAYER:
		player.add_child(summonee)
		playerSummonActive = true
		playerCreature = summonee
	elif summoner == Summoner.ENEMY:
		enemy.add_child(summonee)
		enemySummonActive = true
		enemyCreature = summonee

	summonee.position = location.position		
		
func doFight():
	var playerAttackValue = 0
	var enemyAttackValue = 0
	
	if playerSummonActive:
		playerAttackValue = playerCreature.hp
		# TODO Animate Here
	if enemySummonActive:
		enemyAttackValue = enemyCreature.hp
		# TODO Animate Here
	
	if playerAttackValue > 0 and enemySummonActive:
		enemyCreature.decreaseHealth(playerAttackValue)
	else:
		enemy.decreaseHealth(playerAttackValue)
		
	if enemyAttackValue > 0 and playerSummonActive:
		playerCreature.decreaseHealth(enemyAttackValue)
	else:
		player.decreaseHealth(enemyAttackValue)
	
	
	
	
	
	
	
	
	
	
	
			
