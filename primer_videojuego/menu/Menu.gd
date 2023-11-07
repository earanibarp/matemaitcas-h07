extends Control


func _on_Button_pressed():
	get_tree().change_scene("res://main/Main.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()
