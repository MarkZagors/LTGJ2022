extends Control

func _input(_event):
	if visible == false:
		return
	
	if Input.is_action_just_pressed("again"):
		var _err = get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("quit"):
		Autoload.quited = true
		var _err = get_tree().change_scene("res://Main.tscn")
