extends Human

func _on_Detection_body_entered(body):
	if "Raccoon" in body.name and !hurting and !has_been_hit and !game_stopped:
		attack(1.0 + (speed - 25.0) / 35.0) #to increase attackspeed when at higher speeds

func _on_Detection2_body_entered(body):
	if "Raccoon" in body.name and !hurting and !has_been_hit and !game_stopped:
		if randi() % 3 == 0: # 1/3 of times netdudes react earlier
			attack(1.0)

func attack(speed):
	animation_player.playback_speed = speed
	animation_player.play("Slash")
	yield(animation_player, "animation_finished")
	$AttackCooldown.start()
	initiate()

func _on_AttackCooldown_timeout(): #After AttackCooldown it checks Detection again
	$Detection/CollisionShape2D2.disabled = true
	$Detection/CollisionShape2D2.disabled = false
