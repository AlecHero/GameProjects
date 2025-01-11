extends AudioStreamPlayer

func music_action(action):
	$AnimationPlayer.play(action)

func sound_play(sound):
	get_node(sound).play()

func sound_stop(sound):
	get_node(sound).stop()
