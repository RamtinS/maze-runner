extends Node

func _on_hard_pressed() -> void:
	Global.is_easy = false
	Global.is_normal = false
	Global.is_hard = true
	get_tree().change_scene_to_file("res://UI/Scenes/LoadingScreen.tscn")

func _on_normal_pressed() -> void:
	Global.is_easy = false
	Global.is_normal = true
	Global.is_hard = false
	get_tree().change_scene_to_file("res://UI/Scenes/LoadingScreen.tscn")

func _on_easy_pressed() -> void:
	Global.is_easy = true
	Global.is_normal = false
	Global.is_hard = false
	get_tree().change_scene_to_file("res://UI/Scenes/LoadingScreen.tscn")
