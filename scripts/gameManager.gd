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
@onready var auidoPlayer = get_parent().get_node("AudioPlayer")

@export var playerCreatureSpawn : Node2D
@export var enemyCreatureSpawn : Node2D

var playerCreature : Node2D = null
var enemyCreature : Node2D = null
var lastSelectedGem : Gem

var battleEndDelay = 3
var battleEndTimer = 0
var endingBattle = false

enum Summoner {
	PLAYER,
	ENEMY
}

var bpm = 120.0
var beatsPerRound = 4
var beatMultiplier = 2
var accruedTime = 0

var gameStarted = false
var playerSummonActive = false
var enemySummonActive = false
var gemsInStack = ["squirrel", "squirrel", "squirrel", "snake", "snake", "bee", "bee", "bee", "bee", "bee"]
var enemyGemsInStack = ["squirrel", "squirrel", "squirrel", "snake", "bee", "bee", "bee", "bee", "bee", "bee"]

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
	
	# This end game checking sucks but I'm in a hurry...
	if playerHealth.currentHealth <= 0 or enemyHealth.currentHealth <=0:
		endingBattle = true
		
	if endingBattle:
		battleEndTimer += delta
	
	if battleEndTimer >= battleEndDelay:
		if playerHealth.currentHealth <= 0:
			loadEndScreen(false)
		else:
			loadEndScreen(true)
	
	if not endingBattle:
		# On the beat do things
		if accruedTime >= (60.0 / bpm) * beatMultiplier: # TODO sync this to the music
			accruedTime = 0
			
			# Idle animations
			if not player.animPlayer.is_playing():
				player.animIdle()			
			
			if not enemy.animPlayer.is_playing():
				enemy.animIdle()
			
			if playerSummonActive and not playerCreature.dead:
				playerCreature.animIdle()
			if enemySummonActive and not enemyCreature.dead:
				enemyCreature.animIdle()
				
			# Gain Mana
			if mana.currentMana >= mana.maxMana:
				#playerHealth.decreaseHealth(0.25) # TODO Evaluate this. It doesn't feel quite right
				#enemy.decreaseHealth(0.25)
				pass
			else:
				playerHealth.increaseHealth(0.25)
				enemy.increaseHealth(0.25)
				mana.increaseMana(1);
				enemy.increaseMana(0.25);
			
			# Get a new gem into hand
			if(gemHand.getEmptySlotCount() > 0):
				gemStack.getGem() # TODO Animate this	
				
			enemy.getGem()

			# Do enemy things
			enemy.enemyTurn()

			# TODO Animate the gem stack trying to bounce out and fill the hand

			# Decrease or reset the beat indicator
			if beatIndicator.currentBeat >= beatsPerRound:
				doFight()
				beatIndicator.resetBeat()
				enemy.setBeatToAct(beatsPerRound)
			else:
				beatIndicator.incrementBeat()


################################################################################t
# Signal Callbacks	
################################################################################
func summonTweenFinished():
	if lastSelectedGem:
		gemBag.addToBag(lastSelectedGem)
		lastSelectedGem.get_parent().remove_child(lastSelectedGem)
		lastSelectedGem = null
		
func onGemSelected(gem):
	if mana.currentMana >= gem.cost and not playerSummonActive: # Check summoning cost
		var tween = create_tween()
		lastSelectedGem = gem

		mana.decreaseMana(gem.cost)
		gemHand.removeGem(gem)
		
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(gem, "global_position", playerCreatureSpawn.global_position, 0.1)
		#tween.tween_property(gem, "size.x", 0.25, 0.5)
		tween.chain().tween_property(gem, "position", gemBag.position, 0.2)
		tween.tween_callback(summonTweenFinished)
		#tween.start()
		
		# Player Summon
		summon(Summoner.PLAYER, playerCreatureSpawn, gem.creatureResource)
		
		auidoPlayer.playSFX("newGem")
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
		player.animCast()
		
		if summonee.flipForPlayer:
			summonee.scale.x = -1 * summonee.scale.x 
			print("flipped for player")
		
		auidoPlayer.playSFX("playerCast")
	
	elif summoner == Summoner.ENEMY:
		enemy.add_child(summonee)
		enemySummonActive = true
		enemyCreature = summonee
		enemy.animCast()
		
		if summonee.flipForEnemy:
			summonee.scale.x = -1 * summonee.scale.x 
			print("flipped for enemy")

	auidoPlayer.playSFX("enemyCast")
	
	summonee.position = location.position		
		
func doFight():
	var playerAttackValue = 0
	var enemyAttackValue = 0
	
	if playerSummonActive:
		playerAttackValue = playerCreature.hp
		playerCreature.animAttack()
	if enemySummonActive:
		enemyAttackValue = enemyCreature.hp
		enemyCreature.animAttack()
	
	if playerAttackValue > 0 and enemySummonActive:
		if playerAttackValue > enemyCreature.hp:
			enemy.decreaseHealth(playerAttackValue - enemyCreature.hp)
		enemyCreature.decreaseHealth(playerAttackValue)
	else:
		enemy.decreaseHealth(playerAttackValue)
		
	if enemyAttackValue > 0 and playerSummonActive:
		if enemyAttackValue > playerCreature.hp:
			player.decreaseHealth(enemyAttackValue - playerCreature.hp)
		playerCreature.decreaseHealth(enemyAttackValue)
	else:
		player.decreaseHealth(enemyAttackValue)
		
		
	if playerSummonActive:
		playerCreature.checkDead()
	if enemySummonActive:
		enemyCreature.checkDead()
	
func loadEndScreen(win : bool)	:
	if win:
		get_tree().change_scene_to_file("res://scenes/endWin.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/endLose.tscn")
	

#func animate_gem_to_hand(gem, target_position):
	#tween.interpolate_property(gem, "position", gem.position, target_position, 1.0, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	#tween.interpolate_property(gem, "scale", gem.scale, Vector2(1.2, 1.2), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	#tween.interpolate_property(gem, "scale", Vector2(1.2, 1.2), Vector2(1.0, 1.0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.5) # Delay this scale down to start after the move has halfway completed
	#tween.start()

#tween.connect("tween_all_completed", self, "_on_animation_complete")
#
#func _on_animation_complete():
	#print("Animation completed!")
	## Update game state or enable interactions	
	
	
	
	
			
