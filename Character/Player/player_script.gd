extends CharacterBody3D

# Audio variables
@onready var kick_audio: AudioStreamPlayer3D = $Kick
@onready var low_health_audio: AudioStreamPlayer3D = $LowHealth

# Player Camera Variables
@onready var Camera_A = $Head/Camera3D
@onready var Camera_B = get_node("../Camera3D")

var mouse_sensitivity: float = 0.001

# Player General Variables
var maxHealth: int = 100
var currentHealth: int;

# Player Movement Variables
@export var normal_speed: int = 6
@export var sprint_speed: int = 12
var speed: int = normal_speed
@export var jump_power: int = 3

# Player Knockback
var knockback_strength: float = 10.0
var knockback_duration: float = 0.5
var knockback_timer: float = 0.0
var is_knocked_back: bool = false
var knockback_direction = Vector3.ZERO

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var indicator = $Indicator

@onready var maze_script = get_node("/root/Node3D/Maze")

# The rotation of the player's head at spawn.
var default_head_rotation: Vector3

var coins: Array = []
var health_items: Array = []

# Dont want to show mouse in game.
func _ready() -> void:
	Input.set_mouse_mode	(Input.MOUSE_MODE_CAPTURED)
	indicator.visible = false 
	head.rotation.y = deg_to_rad(-90) # The players view orientation at spawn. 
	default_head_rotation = head.rotation 
		
	Camera_A.current = true
	Camera_B.current = false
	
	# Set player health
	currentHealth = maxHealth;

func get_health() -> int:
	return currentHealth;
	
func get_max_health() -> int:
	return maxHealth;
	
func checkIfPlayerDead() -> void:
	if currentHealth == 0:
		await get_tree().create_timer(0.1).timeout  # Delay to ensure current operations finish
		get_tree().change_scene_to_file("res://UI/Scenes/GameEnd.tscn")
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			head.rotate_y(- event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func take_damage(damage: int, knockback_dir: Vector3 = Vector3.ZERO, knockback_force: float = 0.0) -> void:
	# Apply damage
	currentHealth = max(0, currentHealth - damage)
	kick_audio.play()
	# Only apply knockback if a valid force is provided
	if knockback_force > 0.0:
		knockback_direction = knockback_dir.normalized() * knockback_force
		knockback_timer = knockback_duration
		is_knocked_back = true

func addHealth(givenHealth: int) -> void:
	if (currentHealth + givenHealth > maxHealth):
		currentHealth = maxHealth
	else:
		currentHealth += givenHealth

func _physics_process(delta: float) -> void:
	if !is_inside_tree():
		return
	
	checkIfPlayerDead()
	
	# Handle knockback
	if is_knocked_back:
		if knockback_timer > 0:
			# Apply knockback force and decrease the timer
			velocity.x = knockback_direction.x
			velocity.z = knockback_direction.z
			knockback_timer -= delta
		else:
			# Stop knockback when the timer ends
			is_knocked_back = false
			knockback_direction = Vector3.ZERO
	
	# Normal player movement if not knocked back
	if not is_knocked_back:
		handle_sprint(delta)
		apply_gravity(delta)
		handle_jump()
		var direction = get_input_direction()
		handle_movement(direction, delta)
		
	move_and_slide()

	# Check if low health audio should play or stop.
	if currentHealth <= 20:
		if not low_health_audio.playing:
			low_health_audio.play()
	else:
		if low_health_audio.playing:
			low_health_audio.stop()

# Handle sprint
func handle_sprint(delta: float) -> void:
	if Input.is_action_pressed("shift") or Camera_B.current == true:
		speed = sprint_speed
	else:
		speed = normal_speed

# Handle gravity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# Handle jump
func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_power

# Get the input direction for player movement
func get_input_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

# Handle movement based on whether the player is on the floor or in the air
func handle_movement(direction: Vector3, delta: float) -> void:
	if is_on_floor():
		handle_ground_movement(direction, delta)
	else:
		handle_air_movement(direction, delta)

# Handle movement on the ground
func handle_ground_movement(direction: Vector3, delta: float) -> void:
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)

# Handle movement in air
func handle_air_movement(direction: Vector3, delta: float) -> void:
	velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)



func _input(event: InputEvent) -> void:
	if event.is_action_released("camera_switch"):
		if Camera_A.current == true:
			Camera_B.current = true
			Global.first_person_view = false
			indicator.visible = true 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Disable mouse capture.
			speed = sprint_speed
			head.rotation = default_head_rotation
			update_health_items()
			update_coins()
		else:
			Camera_A.current = true
			Global.first_person_view = true
			indicator.visible = false 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Enable mouse capture.
			speed = normal_speed
			update_health_items()
			update_coins()


func _on_maze_coins_placed() -> void:
	coins = maze_script.coin_instances


func _on_maze_health_placed() -> void:
	health_items = maze_script.health_instances


func update_coins() -> void:
	for coin in coins:
		if coin != null and coin.is_inside_tree():
			if (Camera_A.current == true):
				coin.scale = Vector3(1.0, 1.0, 1.0) 
				coin.position.y = 1.5
			else:
				coin.scale = Vector3(3.0, 3.0, 3.0) 
				coin.position.y = 11


func update_health_items() -> void: 
	for health_item in health_items:
		if health_item != null and health_item.is_inside_tree():
			if (Camera_A.current == true):
				health_item.scale = Vector3(1.0, 1.0, 1.0) 
				health_item.position.y = 1.5
			else:
				health_item.scale = Vector3(2.5, 2.5, 2.5) 
				health_item.position.y = 11


func update_player() -> void:
	if (Camera_A.current == true):
		scale =  Vector3(0.9, 0.9, 0.9)
		position.y = 1
	else:
		scale = Vector3(3.0, 3.0, 3.0) 
		position.y = 12
