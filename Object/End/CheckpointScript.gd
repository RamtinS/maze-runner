extends Area3D

var rotation_speed: float = 1.0  
	
# Apply constant rotation to object
func _physics_process(delta: float) -> void:
	self.rotate_x(0.5 * delta * rotation_speed)
	self.rotate_y(0.9 * delta * rotation_speed)
	self.rotate_z(0.3 * delta * rotation_speed)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://UI/Scenes/GameWin.tscn")
