extends Human

var Bullet = preload("res://Prefabs/Bullet.tscn")

func summon_bullet():
	var bullet = Bullet.instance()
	bullet.initiate(self.position + Vector2(current_direction * 17, -24), current_direction)
	self.get_parent().add_child(bullet)

func _on_Range_body_entered(body):
	if "Seagull" in body.name and !hurting and !has_been_hit and !($AttackCooldown.time_left > 0) and !game_stopped and self.position.x > 0 and self.position.x < 400:
		if randi() % 4 == 0: # 1/4 of shots are done 3x faster
			attack(3.0)
		else:
			attack(1.0)

func attack(speed):
	animation_player.playback_speed = speed
	animation_player.play("Shoot")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Shoot" and !has_been_hit:
		animation_player.playback_speed = 1.0
		initiate(body_type + 1)
		$AttackCooldown.start()

func _on_AttackCooldown_timeout():
	$Range/CollisionPolygon2D.disabled = true
	$Range/CollisionPolygon2D.disabled = false


