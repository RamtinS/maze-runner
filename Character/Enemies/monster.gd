extends CharacterBody3D

# Objects under monster
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D

# Indicator for 2D view.
@onready var indicator = $Indicator

# Movement Variables
var normal_speed = 2
var sprint_speed = 4
var speed;

# Wandering Variables
var wander_radius = 10

# Goofing around variables
var is_looking_around = false
var look_timer = 2.0
var look_timer_elapsed = 0.0

# Hunt Mechanic Variables.  
var tracked_player;
var last_seen_position;
var is_looking;
var is_hunting;

func _ready() -> void:
	set_random_location();
	is_looking = true;
	is_hunting = false;
	speed = normal_speed
	indicator.visible = false 

func set_random_location():
	var random_position := global_position
	
	random_position.x += randf_range(-wander_radius, wander_radius)
	random_position.z += randf_range(-wander_radius, wander_radius)
	 
	navigation_agent.set_target_position(random_position)

func face_direction(direction: Vector3, delta: float):
	if direction.length() > 0:
		var current_forward = -global_transform.basis.z.normalized()
		var target_angle = current_forward.angle_to(-direction)
		
		# Slowly rotates the monster in the direction as it is walking.
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), 5.0 * delta)

func _physics_process(delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if is_looking_around:
		look_around(delta)  # Call the function to handle the look-around behavior
	elif is_hunting:
		hunt_player(delta)
	else:
		wander(delta)
	
	if Global.first_person_view == true:
		indicator.visible = false
	else:
		indicator.visible = true

func look_around(delta: float) -> void:
	animation_tree["parameters/conditions/isLooking"] = false
	animation_tree["parameters/conditions/isHunting"] = false
	animation_tree["parameters/conditions/idle"] = true
	
	look_timer_elapsed += delta
	if look_timer_elapsed < look_timer:
		if tracked_player:
			
			#If player is discovered. FOLLOW HIM!
			is_looking_around = false
			is_hunting = true
			return  # Exit look around
	else:
		# Stop looking around and return to previous state (wandering or hunting)
		is_looking_around = false
		look_timer_elapsed = 0.0
		if tracked_player:
			is_hunting = true
		else:
			is_hunting = false

func hunt_player(delta: float) -> void:
	animation_tree["parameters/conditions/isLooking"] = false
	animation_tree["parameters/conditions/isHunting"] = true
	animation_tree["parameters/conditions/idle"] = false
	speed = sprint_speed;

	if navigation_agent.is_navigation_finished():
		is_hunting = false
	if tracked_player:
		last_seen_position = tracked_player.global_position

	navigation_agent.set_target_position(last_seen_position)
	
	var destination = navigation_agent.get_next_path_position()
	
	# Get the next position along the path and move towards it
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()
	velocity = direction * speed

	# Face the direction of movement smoothly
	face_direction(direction, delta)
	move_and_slide()


# Handles wandering movement
func wander(delta: float):
	animation_tree["parameters/conditions/isLooking"] = true
	animation_tree["parameters/conditions/isHunting"] = false
	animation_tree["parameters/conditions/idle"] = false
	
	speed = normal_speed
	if navigation_agent.is_navigation_finished():
		set_random_location()
		
		# Random chance to stop and look around
		if randf() < 0.50:  # 20% chance to stop and look around
			is_looking_around = true
			return  # Exit this function and start looking around
			
	else:
		# Get the next position along the path and move towards it
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_transform.origin).normalized()
		velocity = direction * normal_speed

		# Face the direction of movement smoothly
		face_direction(direction, delta)
		move_and_slide()


# The monster can smell the player, and is approaching its current position.
func _on_outer_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		audio_stream.play()
		tracked_player = body
		is_hunting = true
		is_looking = false
		pass # Replace with function body.


# The monster has LOST the player, but still sniffs its last position.
func _on_outer_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		audio_stream.stream_paused = true
		is_hunting = true
		tracked_player = null
		pass # Replace with function body.


# The monster is within the players vicinity.
func _on_inner_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var knockback_dir = body.global_position - global_position
		
		var damage: int
		
		if Global.is_hard:
			damage = 50
		elif Global.is_normal:
			damage = 40
		elif Global.is_easy:
			damage = 30
		else: 
			damage = 40
		
		body.take_damage(damage, knockback_dir, 10.0)
		
