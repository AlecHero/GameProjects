extends Control

onready var button_resume = $MarginContainer/Buttons/Resume
onready var button_options = $MarginContainer/Buttons/Options
onready var button_back = $MarginContainer/Buttons/Back

var window_modes = {false:"WINDOWED", true:"BORDERLESS"}
var screen_string

func _ready():
	screen_string = window_modes[General.read_savegame()["Borderless"]]
	$Node2D.z_index = 0

func _input(event):
	if event.is_action_pressed("Pause"):
		pause()

func pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	button_resume.grab_focus()

func _process(_delta):
	if not get_tree().paused and visible:
		get_tree().paused = true

func focus_change(focus_num):
	$Focus.play()
	if focus_num == 1:
		button_resume.text = ".RESUME"
	else:
		button_resume.text = " RESUME"
	if focus_num == 2:
		button_options.text = "." + screen_string
	else:
		button_options.text = " " + screen_string
	if focus_num == 3:
		button_back.text = ".BACK"
	else:
		button_back.text = " BACK"

func _on_Resume_pressed():
	$Select.play()
	pause()

func _on_Options_pressed(): #DISABLE FOR WEB-VERSION
	$Select.play()
	screen_string = window_modes[!General.borderless]
	$MarginContainer/Buttons/Options.text = "." + screen_string
	General.set_borderless(!General.borderless)

func _on_Back_pressed():
	$Select.play()
	$Node2D.z_index = 1
	get_tree().change_scene("Titlescreen.tscn")

func _on_Resume_focus_entered():
	focus_change(1)

func _on_Options_focus_entered():
	focus_change(2)

func _on_Back_focus_entered():
	focus_change(3)
