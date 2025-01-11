extends KinematicBody2D

signal points_got(x)
signal seagull_game_over

const SPEED = 70
const GRAVITY = 4
const JUMP_POWER = -140
const BREAK_FORCE = 0.4
const POOP_POWER = -100

export var Poop : PackedScene

export var invincible := false
export(int, 0, 3, 1) var health_start
var health_current : int

var reward = 10
export(float) var rate_of_fire = 2.0
var can_poop = true

var is_hurting := false
var can_fly = true
var flight_cooldown = 0.4
var velocity = Vector2()

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var pos = $Position

export var velo_y := 0.0
var current_y : float
var booler : bool
var dead := false

func _ready():
	health_current = health_start
	animation_player.play("Idle")

func _process(_delta):
	AnimationLoop()

func _physics_process(_delta):
	if not booler:
		MovementLoop()
		PoopLoop()
	else:
		position.y = current_y + velo_y

func AnimationLoop():
	if Input.is_action_pressed("ui_right"):
		sprite.flip_h = true
	elif Input.is_action_pressed("ui_left"):
		sprite.flip_h = false
	
	if is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			animation_player.play("Move")
		else:
			animation_player.play("Idle")
	else:
		if Input.is_action_pressed("ui_up"):
			animation_player.play("Jump")
		else:
			yield(get_node("AnimationPlayer"),"animation_finished")
			animation_player.play("Idle Flight")

func MovementLoop():
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	elif !is_on_floor():
		if velocity.x < 0:
			velocity.x += BREAK_FORCE
		else:
			velocity.x -= BREAK_FORCE
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("ui_up") and can_fly:
		can_fly = false
		Music.sound_play("SeagullJump")
		velocity.y = JUMP_POWER
		$FlightCooldown.start()
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_FlightCooldown_timeout():
	can_fly = true

func play_anim():
	booler = true
	current_y = position.y
	$AnimationPlayer2.playback_speed = 0.5
	$AnimationPlayer2.play("New Anim")
	$AnimationPlayer.stop()
	
func PoopLoop():
	if Input.is_action_pressed("ui_down") and can_poop:
		Music.sound_play("SeagullPoop")
		animation_player.play("Poop")
		velocity.y = POOP_POWER
		
		can_poop = false
		var poop = Poop.instance()
		poop.position = pos.global_position
		get_parent().add_child(poop)
		yield(get_tree().create_timer(rate_of_fire),"timeout")
		can_poop = true

func hurt():
	if $HurtCooldown.time_left > 0 or invincible:
		return
	
	health_current -= 1
	
	if health_current <= 0 and !dead:
		dead = true
		emit_signal("seagull_game_over")
		sprite.hide()
		Music.sound_play("SeagullHurt")
		$Particles2D.visible = true
		$Particles2D.emitting = true
		$PickupDetection/CollisionShape2D.set_deferred("disabled", true)
		return
	
	if dead:
		return
	
	Music.sound_play("SeagullHurt")
	animation_player.play("Poop")
	velocity.y = POOP_POWER * 1.5
	$HurtCooldown.start()

func _on_PickupDetection_area_entered(area):
	if "DropHotdog" in area.name:
		area.queue_free()
		emit_signal("points_got", reward)
		Music.sound_play("Pickup")
	if "Bullet" in area.name:
		area.queue_free()
		hurt()
	if "Human" in area.name:
		hurt()


