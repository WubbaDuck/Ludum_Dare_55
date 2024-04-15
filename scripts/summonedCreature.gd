extends Node2D

@onready var gm = get_node("/root/Game/GameManager")
@onready var animPlayer = $AnimationPlayer
@onready var healthBar = $HealthBar
@onready var audioPlayer = get_tree().current_scene.get_node("AudioPlayer")

@export var flipForEnemy = false
@export var flipForPlayer = false

var creatureName = "Nobody"
var cost = 1
var hp = 1
var gemColor = Color(1, 1, 1)
var dead = false
var animationQueue = []
var attackSoundName = ""

signal creature_died(creature)

func _ready():
	gm.connectSignal(self, "creature_died", gm.onCreatureDied)
	animPlayer.connect("animation_finished", onAnimPlayerFinished)
	healthBar.max_value = hp
	healthBar.value = hp

func init(source : Creature):
	cost = source.cost
	hp = source.hp
	attackSoundName = source.attackSoundName

func decreaseHealth(amount):
	hp -= amount
	
func increaseHealth(amount):
	hp += amount
	
func checkDead():
	if hp <= 0:
		dead = true
		animDied()

func queueAnimation(animName, priority = false):
	if priority:
		animationQueue.insert(0, animName)
	else:
		animationQueue.append(animName)

func playNextAnimation():
	if animationQueue.size() > 0 and not animPlayer.is_playing():
		var nextAnim = animationQueue.pop_front()
		animPlayer.play(nextAnim)

func animIdle():
	#animPlayer.play("idle")
	queueAnimation("idle")
	playNextAnimation()
	
func animAttack():
	#animPlayer.play("attack")
	queueAnimation("attack", true)
	playNextAnimation()
	
func animDied():
	#animPlayer.play("die")
	queueAnimation("die")
	playNextAnimation()
	
func onAnimPlayerFinished(animName):
	if animName == "attack":
		audioPlayer.playSFX(attackSoundName)
		healthBar.value = hp
	if animName == "die":
		emit_signal("creature_died", self)
	else:
		playNextAnimation()
