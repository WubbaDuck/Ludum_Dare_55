extends Node

var beeAttack = preload("res://assets/sound/beeAttack.wav")
var snakeAttack = preload("res://assets/sound/snakeAttack.wav")
var squirrelAttack = preload("res://assets/sound/squirrelAttack.wav")
var newGem = preload("res://assets/sound/newGem.wav")
var playerCast = preload("res://assets/sound/playerCast.wav")
var enemyCast = preload("res://assets/sound/enemyCast.wav")

func playSFX(name: String):
	var stream = null
	
	if name == "beeAttack":
		stream = beeAttack
		
	elif name == "snakeAttack":
		stream = snakeAttack
		
	elif name == "squirrelAttack":
		stream = squirrelAttack
		
	elif name == "newGem":
		stream = newGem
		
	elif name == "playerCast":
		stream = playerCast
		
	elif name == "enemyCast":
		stream = enemyCast
	else:
		return
	
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.name = "SFX"
	add_child(asp)
	asp.play()

	await asp.finished
	
	asp.queue_free()
