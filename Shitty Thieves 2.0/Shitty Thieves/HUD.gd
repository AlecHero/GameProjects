extends Node2D

onready var seagull = get_node("../../Seagull")
onready var raccoon = get_node("../../Raccoon")

var score := 0

func add_score(x):
	score += x
	$Score.text = "%06d" % score

func _ready():
	add_score(0)

func _process(_delta):
	IconLoop()

func IconLoop():
	$RaccoonLife.frame = raccoon.health_current
	$RaccoonSpecial.visible = raccoon.can_attack
	
	$SeagullLife.frame = seagull.health_current
	$SeagullSpecial.visible = seagull.can_poop
	
	if seagull.is_on_floor() and (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		$AnimationGull.play("Seagull")
	elif Input.is_action_pressed("ui_up") and seagull.can_fly:
		$AnimationGull.play("Seagull")
	
	if raccoon.is_on_floor() and (Input.is_action_pressed("Right") or Input.is_action_pressed("Left")):
		$AnimationCoon.play("Raccoon")

func _on_Raccoon_points_got(x):
	add_score(x)

func _on_Seagull_points_got(x):
	add_score(x)


func _on_Raccoon_raccoon_game_over():
	$RaccoonIcon.frame = 2
	$RaccoonLife.frame = raccoon.health_current
	set_process(false)

func _on_Seagull_seagull_game_over():
	$SeagullIcon.frame = 3
	$SeagullLife.frame = seagull.health_current
	set_process(false)
