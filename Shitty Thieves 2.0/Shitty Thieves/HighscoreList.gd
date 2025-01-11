extends Node2D

var highscore_list : Array
var highscore_string := ""
var is_visible = true
var timer_started = false

onready var new_best = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/NewBest
onready var current = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/Current
onready var scores = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/Scores

func on_spawn():
	$InitialBlinkingTimer.start()
	$Label.percent_visible = 0.0
	
	highscore_string = ""
	highscore_list = General.read_savegame()["Highscore List"]
	var score_pos = General.score_pos
	
	for score in range(highscore_list.size()):
		if score_pos == 0: #If best
			new_best.text = "NEW BEST"
		if score == score_pos: #If current
			for _i in range(score_pos):
				current.text += "\n"
			current.text += "."
		highscore_string += "%06d" % highscore_list[score] + "\n"
	scores.text = highscore_string
	
func _on_InitialBlinkingTimer_timeout():
	$BlinkingTimer.start()
	timer_started = true

func _on_BlinkingTimer_timeout():
	if is_visible:
		current.percent_visible = 1.0
#		new_best.percent_visible = 1.0
		$Label.percent_visible = 1.0
	else:
		current.percent_visible = 0.0
#		new_best.percent_visible = 0.0
		$Label.percent_visible = 0.0
	is_visible = !is_visible

