extends Node2D

onready var raccoon = $Viewport/Raccoon
onready var seagull = $Viewport/Seagull
onready var spawn_timer = $TimerSpawn
onready var pos_left = $SpawnLeft.position
onready var pos_right = $SpawnRight.position

const SPEED_MAX = 45.0
const SPEED_MIN = 25.0
var speed := 25.0

var seagull_dead := false
var raccoon_dead := false

var HumanHotdog = preload("res://Prefabs/Characters/HumanHotdog.tscn")
var HumanMoney = preload("res://Prefabs/Characters/HumanMoney.tscn")
var HumanGun = preload("res://Prefabs/Characters/HumanGun.tscn")
var HumanNet = preload("res://Prefabs/Characters/HumanNet.tscn")

export(float) var hotdog_chance = .35
export(float) var money_chance = .35
export(float) var gun_chance = .15
export(float) var net_chance = .15

var initial_type_weight : Dictionary
var type_weight : Dictionary #Dictionary that gets changed throughout
var type_weight_increase = 0.1

var initial_dir_choices = {-1:0.5, 1:0.5}
var dir_choices = initial_dir_choices.duplicate()
var dir_weight_increase = 1.0


func _ready():
	initial_type_weight = { #The initial dictionary
		HumanHotdog: hotdog_chance,
		HumanMoney: money_chance,
		HumanGun: gun_chance,
		HumanNet: net_chance
	} 
	type_weight = initial_type_weight.duplicate()
	
	randomize() #To randomize the enemy spawns
	Music.music_action("FadeIn")
	$PauseLayer/PauseScreen.visible = false
	$AnimationPlayer.play("Intro")
	set_character_process(false)
	set_character_physics(false)
	debug_update()

#func _process(delta):
#	if Input.is_action_just_pressed("Debug"):
#		$Debug/HBoxContainer.visible = !$Debug/HBoxContainer.visible

func debug_update():
	$Debug/HBoxContainer/weight_table.text = str(type_weight.values())
	$Debug/HBoxContainer/human_speed.text = str(speed)
	$Debug/HBoxContainer/spawn_timer.text = str(spawn_timer.wait_time)

func game_over():
	if seagull_dead or raccoon_dead:
		return
	General.add_score($Viewport/HUD/HUD.score)
	set_character_process(false)
	move_characters()
	
	spawn_timer.stop()
	$Debug/HBoxContainer.visible = false
	
	$AnimationPlayer.playback_speed = 0.5
	$AnimationPlayer.play("GameOver")
	Music.sound_play("GameOver")
	Music.music_action("FadeOut")

func move_characters():
	for obj in $Viewport.get_children():
		if "Human" in obj.name:
			obj.play_anim()
		if "DropMoney" in obj.name:
			obj.queue_free()
	seagull.play_anim()
	raccoon.play_anim()

func set_character_process(booler: bool):
	raccoon.set_process(booler)
	seagull.set_process(booler)
func set_character_physics(booler: bool):
	raccoon.set_physics_process(booler)
	seagull.set_physics_process(booler)

func spawner(dir, type):
	var human = type.instance()
	human.set_direction(dir)
	human.speed = speed
	human.position = (pos_right if dir == -1 else pos_left)
	
	$Viewport.add_child(human)

func _on_TimerSpawn_timeout():
	spawner(
		General.weighted_average(initial_dir_choices, dir_choices, dir_weight_increase),
		General.weighted_average(initial_type_weight, type_weight, type_weight_increase)
	)
	debug_update()

func _on_TimerIncrement_timeout():
	if speed < SPEED_MAX:
		speed += (SPEED_MAX - SPEED_MIN) / 15.0
		spawn_timer.wait_time -= (2.5 - 1.0) / 15.0
	debug_update()

func _on_Seagull_seagull_game_over():
	game_over()
	seagull_dead = true

func _on_Raccoon_raccoon_game_over():
	game_over()
	raccoon_dead = true
