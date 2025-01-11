extends Area2D
class_name Human

export var Drop : PackedScene
export var current_direction = 1
export(int, 0, 11) var body_type
export(String, "Shitted", "Hurt") var hurt_by

export var hurting := false #Gets altered in the animation_player
export var velo_y := 131.0 #Gets altered in the animation_player
export var is_attacking := false #Gets altered in the animation_player

onready var face = $Face
onready var body = $Body
onready var animation_player = $AnimationPlayer

var speed := 30.0
var run_speed := speed + 15.0
var velocity = Vector2()
var has_been_hit = false
var game_stopped : bool #Gets altered in the animation_player???


func _ready():
	hurting = false
	is_attacking = false
	has_been_hit = false
	set_physics_process(true)
	initiate(body_type + 1)
	position.y = 131

func hit(attack_type):
	animation_player.playback_speed = 1.0
	
	if is_attacking and attack_type != hurt_by: #The wrong attack type can't hurt while they're attacking
		pass
	elif !has_been_hit and attack_type == hurt_by: #The right attack type will always hurt
		has_been_hit = true
		summon_drop()
		body.frame = body_type
		hurt_run(attack_type, true)
	else:
		hurt_run(attack_type, (true if body_type <= 2 else false)) #Run away only if you are hotdog or money -man
	
	if $Body.frame == 7: #Fixes humanGun's animation when pooped exactly when shooting
		$Body.frame = 6
	Music.sound_play(attack_type + "Sound")

func set_direction(dir := current_direction):
	self.scale.x = dir
	current_direction = dir

func hurt_run(anim, has_drop): #Play the relevant hurt animation
	animation_player.play(anim)
	yield(animation_player, "animation_finished")
	animation_player.play("Walk")
	
	if has_drop: #If you hit a food-type with the wrong attack they will run away.
		speed = run_speed
		if position.x < 200:
			set_direction(-1)
		else:
			set_direction(1)

func initiate(frame:= body.frame):
	body.frame = frame
	set_direction()
	animation_player.play("Walk")

func summon_drop():
	var instance = Drop.instance()
	if "direction" in instance:
		instance.direction = current_direction
	instance.position = self.position
	instance.request_ready()
	self.get_parent().call_deferred("add_child", instance)

func play_anim():
	game_stopped = true
	$AnimationPlayer2.playback_speed = 0.5
	$AnimationPlayer2.play("GameOverGoDown")
	if $AnimationPlayer.current_animation == "Slash" or $AnimationPlayer.current_animation == "Shoot" or $AnimationPlayer.current_animation == "Hurt" or $AnimationPlayer.current_animation == "Shitted":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Walk")
		initiate()
		set_physics_process(true)
	if $Body.frame == 10 or $Body.frame == 11 or $Body.frame == 12:
		$Body.frame = 9

func _physics_process(delta):
	velocity.x = speed * delta * current_direction
	translate(velocity)
	self.position.y = velo_y

func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
