extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Difficulty.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/MainMenu.tscn")


func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Tutorial.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Tutorial2.tscn")
