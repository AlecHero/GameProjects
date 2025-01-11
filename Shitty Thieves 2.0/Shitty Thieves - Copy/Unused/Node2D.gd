extends Node2D
var highscore_list

onready var button_sort = $sort
onready var button_add = $add
onready var score_input = $add/input
onready var label_score = $score
onready var score_number = $score/number

func _ready():
	General.read_savegame()
	score_number.text = str(General.read_savegame()["Highscore List"])
	$Label.text = str(General.read_savegame()["Borderless"])

func _on_add_pressed():
	General.add_score(int($add/input.text))
	$score/number.text = str(General.highscore_list)
