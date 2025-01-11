extends Area2D

onready var animation_player = $AnimationPlayer

var velocity = Vector2()
var direction = 1

const SPEED = 50
const GRAVITY = 1
const THROW_POWER = 100

func _ready():
	velocity.y -= THROW_POWER
	velocity.x += SPEED * direction

func _physics_process(delta):
	velocity.y += GRAVITY
	translate(velocity * delta)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Hotdog_body_entered(body):
	if "Wall" in body.get_name():
		velocity = velocity.reflect(Vector2.UP)
