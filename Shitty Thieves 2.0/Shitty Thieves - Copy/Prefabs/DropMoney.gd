extends Area2D

var velocity = Vector2()
var blink_amount = 0

func _physics_process(delta):
	velocity.y += 1
	if position.y < 159:
		translate(velocity * delta)

func _on_TimerInitial_timeout():
	$TimerHide.start()

func _on_TimerHide_timeout():
	if blink_amount >= 4:
		$TimerHide.wait_time = 0.6
	if blink_amount >= 8:
		queue_free()
	
	blink_amount += 1
	$Sprite.visible = false
	$TimerShow.start()

func _on_TimerShow_timeout():
	$Sprite.visible = true
