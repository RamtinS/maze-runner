extends Area3D

# Rotate variables
var turn_incrememt  = 1

@onready var audio_player = $AudioStreamPlayer3D  

# Rotates the coin.
func _physics_process(delta: float) -> void:
	self.rotate_y(turn_incrememt * delta)

# Event which plays when player touches coin
func _on_body_entered(body: Node3D) -> void:
	if body.get_parent_node_3d().get_parent_node_3d().is_in_group("Player"):
		body.get_parent_node_3d().get_parent_node_3d().addHealth(20)
		self.hide()
		$CollisionShape3D.set_deferred("disabled", true)  # Disable the collision shape.
	
		audio_player.play()
		await audio_player.finished
		
		self.queue_free() # Remove the coin.
	elif body.is_in_group("Player"):
		body.addHealth(20)
		self.hide()
		$CollisionShape3D.set_deferred("disabled", true)  # Disable the collision shape.
	
		audio_player.play()
		await audio_player.finished
		
		self.queue_free() # Remove the coin.
