extends Control

func _ready() -> void:
	# Activate the mouse when the menu scene is ready
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Difficulty.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
