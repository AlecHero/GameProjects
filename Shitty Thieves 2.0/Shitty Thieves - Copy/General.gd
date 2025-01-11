extends Node

var savegame = File.new() #file
const save_path = "user://savegame.save" #place of the file

var save_dict = {}
var default_dict = {
	"Highscore List": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"Borderless": false
}
var highscore_list
var borderless
var score_pos = 10

func _ready():
	read_savegame()
	highscore_list = save_dict["Highscore List"]
	borderless = save_dict["Borderless"]

#func _notification(notification): #DISABLE FOR WEB-VERSION
#	match notification:
#		MainLoop.NOTIFICATION_WM_FOCUS_IN:
#			get_tree().paused = false
#		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#			get_tree().paused = true

func add_score(new_score):
	read_savegame()
	highscore_list = save_dict["Highscore List"]
	for list_score in highscore_list:
		if new_score > list_score:
			score_pos = highscore_list.find(list_score)
			highscore_list.insert(score_pos, new_score)
			highscore_list.resize(10)
			break
	save()

func save():
	savegame.open(save_path, File.WRITE) #open file to write
	savegame.store_var(save_dict) #store the data
	savegame.close() # close the file

func read_savegame():
	if not savegame.file_exists(save_path): #First save
		save_dict = default_dict.duplicate()
		save()
	
	savegame.open(save_path, File.READ) #open the file
	save_dict = savegame.get_var() #get the value
	if save_dict["Highscore List"] == null or save_dict["Borderless"] == null: #if save is fucked just reset
		save_dict = default_dict.duplicate()
	savegame.close() #close the file
	
	return save_dict

func set_borderless(mode := borderless):
	read_savegame()
	OS.window_borderless = mode
	
	if !mode and !borderless: #Don't recenter/resize if it's already windowed
		pass
	elif !mode: #If windowed mode, set size and recenter
		OS.set_window_size(Vector2(800, 450))
		OS.center_window()
	elif mode: #Don't set maximize = mode when mode is false
		OS.window_maximized = mode
	
	borderless = mode
	save_dict["Borderless"] = mode
	save()

func weighted_average(initial, current, weight_increase):
	var selected
	var sum_weight = 0.0
	for weight in current.values():
		sum_weight += weight
	
	for type in current.keys():
		var rand_num = randf()
		if current[type] / sum_weight >= rand_num:
			selected = type
			break
		else:
			sum_weight -= current[type]
	
	current[selected] = initial[selected]
	for type in current.keys():
		if type != selected:
			current[type] += weight_increase
	
	return selected
