extends Area2D

const SPEED = 70

var direction
var velocity = Vector2()

func initiate(pos, dir):
	self.scale.x = dir
	position = pos
	direction = dir
	velocity = Vector2(direction * SPEED, -SPEED)
	Music.sound_play("GunSound") #Maybe sound shouldn't be played from here?

func _physics_process(delta):
	translate(velocity * delta)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
