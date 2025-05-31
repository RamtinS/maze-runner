extends Control

@onready var textLabel = $CanvasLayer/Label
@onready var timeLabel = $CanvasLayer/CenterContainer/GridContainer/CenterContainer/VBoxContainer/Time
@onready var goldLabel = $CanvasLayer/CenterContainer/GridContainer/CenterContainer/VBoxContainer/Gold

var winnerQuotes = {
	1: "You outsmarted the Monster!",
	2: "Victory! The maze couldn't hold you.",
	3: "You escaped with your life!",
	4: "Well done, you beat the labyrinth!",
	5: "The Monster stands no chance against you!",
	6: "Another victory in the maze!",
	7: "You're the master of the labyrinth!",
	8: "You outwitted the beast and won!",
	9: "No maze is too challenging for you!",
	10: "You've escaped the Monster's lair!"
}

func _ready() -> void:
	var random_index = randi() % 10 + 1
	textLabel.text = winnerQuotes[random_index]
	goldLabel.text = "Gold collected: " + str(PlayerStats.get_collected_coins())
	timeLabel.text = "Time used: " + str(PlayerStats.get_time())
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/Difficulty.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/MainMenu.tscn")
