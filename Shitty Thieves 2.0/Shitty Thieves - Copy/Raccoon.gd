extends KinematicBody2D

signal points_got(x)
signal raccoon_game_over

const SPEED = 70
const GRAVITY = 12
const JUMP_POWER = -250

export var invincible := false
export(int, 0, 3, 1) var health_start
var health_current : int

var reward = 10
var velocity = Vector2()
var can_attack := true
export var has_attacked := false

onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite


func _ready():
	health_current = health_start
	animation_player.play("Idle")
	$Attack/AttackHitbox.disabled = true

func _physics_process(_delta):
	if not booler:
		MovementLoop()
	else:
		position.y = current_y + velo_y

func _process(_delta):
	AnimationLoop()

func AnimationLoop():
	if !is_on_floor():
		animation_player.play("Jump")
	elif Input.is_action_just_pressed("Down") and is_on_floor() and can_attack:
		can_attack = false
		animation_player.play("Attack")
		set_process(false)
	elif Input.is_action_pressed("Left") or Input.is_action_pressed("Right") and !Input.is_action_pressed("Up"):
		animation_player.play("Move")
	else:
		animation_player.play("Idle")
	
	if velocity.x < 0:
		sprite.flip_h = true
		$Attack.scale.x = -1
	elif velocity.x > 0:
		sprite.flip_h = false
		$Attack.scale.x = 1

func MovementLoop():
	if Input.is_action_pressed("Right"):
		velocity.x = SPEED
	elif Input.is_action_pressed("Left"):
		velocity.x = -SPEED
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("Up") and is_on_floor():
		velocity.y = JUMP_POWER
		Music.sound_play("RaccoonJump")
	
	#yield(get_node("AnimationPlayer"),"animation_finished")
	#fun glitchy movement effect
	
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)

export var velo_y := 0.0
var current_y : float
var booler : bool

func play_anim():
	booler = true
	current_y = position.y
	$AnimationPlayer2.playback_speed = 0.5
	$AnimationPlayer2.play("New Anim")
	$AnimationPlayer.stop()

var dead = false
func hurt():
	if $HurtCooldown.time_left > 0 or invincible:
		return
	
	health_current -= 1
	Music.sound_play("RaccoonHurt")
	
	if health_current <= 0 and !dead: #On death
		dead = true
		emit_signal("raccoon_game_over")
		sprite.hide()
		$Particles2D.visible = true
		$Particles2D.emitting = true
		$Attack/AttackHitbox.disabled = true
		$PickupDetection/CollisionShape2D.disabled = true
		return
	
	velocity.y += JUMP_POWER / 3.0
	$HurtCooldown.start()

var attacked_list = []
func _on_Attack_area_entered(area):
	if area.has_been_hit:
		attacked_list.push_back(area)
	else:
		attacked_list.push_front(area)

func attack():
	for i in attacked_list.slice(0, 1):
		i.hit("Hurt")
	attacked_list = []

func _on_PickupDetection_area_entered(area):
	if "Money" in area.name:
		emit_signal("points_got", reward)
		Music.sound_play("Pickup")
		area.queue_free()
	if "NetAttack" in area.name:
		if !area.get_parent().has_been_hit: #THis is a wierd fix to make sure you won't get hit by the collision box even if it should be gone
			hurt()

func _on_AttackCooldown_timeout():
	can_attack = true
