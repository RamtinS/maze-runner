extends Control

@onready var pause_menu = $ColorRect

func _ready() -> void:
	pause_menu.hide()

func unpause():
	pause_menu.hide()
	get_tree().paused = false

	if Global.first_person_view == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func pause():
	pause_menu.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		if get_tree().paused == false:
			pause()
		else:
			unpause()
		
				
func _on_resume_pressed() -> void:
	unpause()

func _on_exit_pressed() -> void:
	get_tree().quit()
