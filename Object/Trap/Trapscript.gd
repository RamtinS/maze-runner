extends Area3D

@onready var animationPlayer = $Sketchfab_Scene/AnimationPlayer
@onready var trigger = $Collision

		
func _on_body_entered(body: Node3D) -> void:
	if animationPlayer.is_playing(): 
		return
		
	if body.is_in_group("Player"):
		body.take_damage(10)
		animationPlayer.play("Anims") 
