extends Node2D

onready var label = $MarginContainer/Label

func _ready():
	label.visible_characters = 0
	label.text = "IT IS YET ANOTHER /nDAY IN THE CITY"
	$AnimationPlayer.play("Part1")
	yield(get_node("AnimationPlayer"),"animation_finished")
	
	
	label.visible_characters = 0
	label.text = "RUSTLING FROM THE ALLEYS"
	$AnimationPlayer.play("Part2")
	yield(get_node("AnimationPlayer"),"animation_finished")
