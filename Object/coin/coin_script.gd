extends Area3D

# Rotate variables
var turn_incrememt  = 1

# Reference to the player stats for updating.
@onready var player_stats = get_node("/root/Node3D/PlayerStats")

@onready var audio_player = $AudioStreamPlayer3D  

# Rotates the coin.
func _physics_process(delta: float) -> void:
	self.rotate_y(turn_incrememt * delta)

# Event which plays when player touches coin
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("Player touched coin.")
		
		self.hide()
		$CollisionShape3D.set_deferred("disabled", true)  # Disable the collision shape.
		
		player_stats.update_coin_count(1)  # Add a coin to player stats.
		
		audio_player.play() # Play coin sound.
		await audio_player.finished # Wait until the sound finishes.
		
		self.queue_free() # Remove the coin.
		
	
