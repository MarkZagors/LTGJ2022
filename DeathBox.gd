extends Area2D


func _on_DeathBox_body_entered(_body):
	var _err = get_tree().reload_current_scene()
