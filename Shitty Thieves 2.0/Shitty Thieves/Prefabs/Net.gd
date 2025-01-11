extends Area2D

const SPEED = 50
const GRAVITY = 1
const THROW_POWER = 100

onready var animation_player = $AnimationPlayer

var velocity = Vector2()
var direction = 1

func _ready():
	$Sprite.scale = Vector2(direction, 1)
	animation_player.play("NetSpin")
	velocity.x += SPEED * direction

func _physics_process(delta):
	velocity.y += GRAVITY
	translate(velocity * delta)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
