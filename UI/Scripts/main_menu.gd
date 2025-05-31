extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Difficulty.tscn")
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Tutorial.tscn")
