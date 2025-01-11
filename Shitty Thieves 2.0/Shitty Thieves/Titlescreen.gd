extends Node

onready var animation_player = $AnimationPlayer
var intro_finished = false
var stage = preload("res://Stage.tscn")
var is_visible = true

func _ready():
	$Viewport/Backdrop.z_index = 1
	Music.sound_stop("GameOver")
	Music.music_action("FadeOut")
	get_tree().paused = false
	animation_player.play("Intro")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #DISABLE FOR WEB-VERSION - MAYBE NOT
	General.set_borderless() #DISABLE FOR WEB-VERSION

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"): #DISABLE FOR WEB-VERSION
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept") and !intro_finished:
		animation_player.seek(2.4, true)
	elif Input.is_action_just_pressed("ui_accept") and intro_finished:
		Music.sound_play("Select")
		get_tree().change_scene_to(stage)
		$Viewport/Backdrop.z_index = 0

func _on_AnimationPlayer_animation_finished(anim):
	if anim == "Intro":
		intro_finished = true
		$BlinkingTimer.start()
		$Viewport/TitleMenu/MarginContainer/VBoxContainer/Start.visible = true

func title_sound():
	$SoundTitle.playing = true

func _on_BlinkingTimer_timeout():
	if is_visible:
		$Viewport/TitleMenu/MarginContainer/VBoxContainer/Start.visible = false
	else:
		$Viewport/TitleMenu/MarginContainer/VBoxContainer/Start.visible = true
		#$Thud.play()
	is_visible = !is_visible
