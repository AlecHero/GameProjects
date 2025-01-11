extends Area2D

const speed = 150
var velocity = Vector2()

func _physics_process(delta):
	velocity.y = speed * delta
	translate(velocity)

func _on_Poop_area_entered(area):
	area.hit("Shitted")
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
