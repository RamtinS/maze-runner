extends Node3D

# Maze dimensions.
var maze_width: int = 55 #55 43 35 23 
var maze_height: int = 53


# Entry and exit positions.
var entry_position: Vector2i
var exit_position: Vector2i

@onready var grid_map = $NavigationRegion3D/GridMap  # Reference the GridMap node.
@onready var navigation_region = $NavigationRegion3D
@onready var player = $Player

# Access the script connected to the node, which in this case is player_stats.
@onready var player_stats = get_node("/root/Node3D/PlayerStats")

# Load the health scene
@onready var health_scene = preload("res://Object/Health/HealthUp.tscn")

@onready var trap_scene = preload("res://Object/Trap/Trap.tscn")
@onready var moving_wall_x = preload("res://Object/Walls/MovingWallX.tscn")
@onready var moving_wall_y = preload("res://Object/Walls/MovingWallY.tscn")

# Load the coin scene
@onready var coin_scene = preload("res://Object/Coin/Coin.tscn")

# Load the exit scene
@onready var exit_scene = preload("res://Object/End/Checkpoint.tscn")

@onready var monster_scene = preload("res://Character/Enemies/Monster.tscn")

# Calculate offsets to center the maze around the origin.
var x_offset: int
var z_offset: int

var maze_layout = [] # 2D array to hold the layout of the maze. 1 for wall and 0 for path.

var max_health_items: int
var max_coins: int
var max_traps: int
var max_moving_walls: int

var health_instances: Array = [] 
var coin_instances: Array = [] # List to store the coin instances.
var trap_instances: Array = []

signal coins_placed
signal health_placed

func _ready():
	
	if Global.is_hard:
		maze_width = 55
		max_health_items = 40
		max_traps = 40
		max_moving_walls = 90
	elif Global.is_normal:
		maze_width = 35
		max_health_items = 20
		max_traps = 20
		max_moving_walls = 70
	elif Global.is_easy:
		maze_width = 23
		max_health_items = 10
		max_traps = 10
		max_moving_walls = 30
	
	entry_position = Vector2i(0, maze_height / 2)
	exit_position = Vector2i(maze_width - 1, maze_height / 2)
	
	max_coins = player_stats.get_max_coins()
	
	x_offset = maze_width / 2
	z_offset = maze_height / 2
	
	create_random_maze()
	remove_random_walls(50)
	place_walls()
	place_spawn_walls()
	place_moving_walls()
	bake_mesh()
	position_player_at_entry()
	add_exit()
	place_health_items()
	place_coins()
	place_trap_items()
	add_monster()



# Recursive backtracking maze generation algorithm
func create_random_maze():
	
	# Initialize maze layout with walls.
	for y in range(maze_height):
		maze_layout.append([])
		for x in range(maze_width):
			maze_layout[y].append(1)
	
	# Create an empty space in the center of the maze. 
	# This will act as the Minotaur's spawn.
	maze_layout[maze_height / 2][maze_width / 2] = 0

	# Start generating the maze from the center.
	carve_paths(maze_width / 2, maze_height / 2)

	# Set the entry and the exit to zero to ensure that they are paths.
	maze_layout[entry_position.y][entry_position.x] = 0
	maze_layout[exit_position.y][exit_position.x] = 0


# Carve paths using recursive backtracking
func carve_paths(x: int, y: int):
	
	# All possible directions the algorithm can take (up, down, left, right). 
	var directions = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]
	directions.shuffle() # Randomized directions to create random maze structure.

	for direction in directions:
		# Calculate the new x coordinate by moving 2 cells in the x direction.
		# By moving to celles each time we ensure that there is a wall between paths.
		var new_x = x + direction.x * 2
		
		# Calculate the new y coordinate by moving 2 cells in the y direction.
		var new_y = y + direction.y * 2

		# If the new coordinates are within the maze, proceed.
		if new_x > 0 and new_y > 0 and new_x < maze_width - 1 and new_y < maze_height - 1:
			if maze_layout[new_y][new_x] == 1:  # If the next cell is a wall, proceed to carve a path.
				maze_layout[y + direction.y][x + direction.x] = 0  # Clear the wall between cells
				maze_layout[new_y][new_x] = 0  # Clear the next cell
				carve_paths(new_x, new_y)  # Recursively carve paths


# Function to randomly remove walls to create additional paths to the exit.
func remove_random_walls(walls_to_remove: int):
	var removed_walls = 0
	
	while removed_walls < walls_to_remove:
		# Randomly choose a position within the maze interior.
		var x = randi_range(1, maze_width - 2)
		var y = randi_range(1, maze_height - 2)

		# Only remove if it is a wall.
		if maze_layout[y][x] == 1:
			maze_layout[y][x] = 0  # Turn the wall into a path.
			removed_walls += 1


# Place the walls in the GridMap.
func place_walls():
	
	for y in range(maze_height):
		for x in range(maze_width):
			if maze_layout[y][x] == 1: # If the value is 1, it represents a wall.
				var adjusted_x = x - x_offset
				var adjusted_z = y - z_offset
				grid_map.set_cell_item(Vector3i(int(adjusted_x), 6, int(adjusted_z)), 1) # Set the wall.


func bake_mesh():
	navigation_region.bake_navigation_mesh(false)


# Function for placing walls around the spawn point.
func place_spawn_walls():
	var position_x = (entry_position.x - x_offset) * 3 - 3
	grid_map.set_cell_item(Vector3(position_x/3, 6, 2), 1)
	grid_map.set_cell_item(Vector3(position_x/3 - 1, 6, 2), 1)
	grid_map.set_cell_item(Vector3(position_x/3 - 2, 6, 1), 1)
	grid_map.set_cell_item(Vector3(position_x/3 - 2, 6, 0), 1)
	grid_map.set_cell_item(Vector3(position_x/3 - 2, 6, -1), 1)
	grid_map.set_cell_item(Vector3(position_x/3, 6, -2), 1)
	grid_map.set_cell_item(Vector3(position_x/3 - 1, 6, -2), 1)


# Function for placing player on the map.
func position_player_at_entry():
	var position_x = (entry_position.x - x_offset) * 3 - 3
	var position_y = 1
	var position_z = 1.5
	
	player.global_transform.origin = Vector3(position_x, position_y, position_z)


# Place health items in the maze. 
func place_health_items():
	var health_items_placed = 0

	var occupied_positions = [] # Array to keep track of occupied positions.
	
	while health_items_placed < max_health_items:
		var x = randi_range(1, maze_width - 2)
		var y = randi_range(1, maze_height - 2)
	
		if maze_layout[y][x] == 0 and not occupied_positions.has(Vector2(x, y)):
			var adjusted_x = (x - x_offset) * 3 + 1.5
			var adjusted_z = (y - z_offset) * 3 + 1.5
			
			var health_instnace = health_scene.instantiate()
			health_instnace.position = Vector3(adjusted_x, 1.5, adjusted_z)
			
			add_child(health_instnace)
			
			health_instances.append(health_instnace)
			
			occupied_positions.append(Vector2(x, y))
			
			health_items_placed += 1
	
	emit_signal("health_placed") 


# Place coins in the maze
func place_coins(): 
	var coins_placed = 0
	
	var occupied_positions = []
	
	# Track all health pickup positions so that it doesnt get picked up.
	for health in health_instances:
		var vector2d = Vector2(health.position.x, health.position.z)
		occupied_positions.append(vector2d)

	while coins_placed < max_coins:
		var x = randi_range(1, maze_width - 2)
		var y = randi_range(1, maze_height - 2)
		
		# Only place a coin where there is a path (0).
		if maze_layout[y][x] == 0 and not occupied_positions.has(Vector2(x, y)):
			var adjusted_x = (x - x_offset) * 3 + 1.5
			var adjusted_z = (y - z_offset) * 3 + 1.5
			
			var coin_instance = coin_scene.instantiate()
			coin_instance.position = Vector3(adjusted_x, 1.5, adjusted_z)
	
			add_child(coin_instance)
			
			coin_instances.append(coin_instance)
			
			occupied_positions.append(Vector2(x, y))
			
			coins_placed += 1
			
	emit_signal("coins_placed") 
	
	
func place_trap_items():
	var trap_items_placed = 0
	
	var occupied_positions = [] # Array to keep track of occupied positions.
	
	# Add health to the occupied position. 
	for health in health_instances:
		var vector2d = Vector2(health.position.x, health.position.z)
		occupied_positions.append(vector2d)
	
	# Add the coins to the occupied position
	for coins in coin_instances:
		var vector2d = Vector2(coins.position.x, coins.position.z)
		occupied_positions.append(vector2d)
		
	while trap_items_placed < max_traps:
		var x = randi_range(1, maze_width - 2)
		var y = randi_range(1, maze_height - 2)
	
		if maze_layout[y][x] == 0 and not occupied_positions.has(Vector2(x, y)):
			var adjusted_x = (x - x_offset) * 3 + 1.5
			var adjusted_z = (y - z_offset) * 3 + 1.5
			
			var trap_instance = trap_scene.instantiate()
			
			# Correct the position to ensure traps are placed at ground level
			trap_instance.position = Vector3(adjusted_x, 0.60, adjusted_z) # Set Y to 1 (ground level)
			
			add_child(trap_instance)
			
			trap_instances.append(trap_instance)
			
			occupied_positions.append(Vector2(x, y))
			
			trap_items_placed += 1
	#emit_signal("T") 
	

func add_exit():
	var exit_instance = exit_scene.instantiate()
	exit_instance.position = Vector3((exit_position.x - x_offset) * 3 - 3 + 8, 2, 1.5)
	add_child(exit_instance)
	

func place_moving_walls():
	var moving_walls_placed = 0
	
	while moving_walls_placed < max_moving_walls:
		var x = randi_range(2, maze_width - 3)
		var y = randi_range(2, maze_height - 3)
		
		if maze_layout[y][x] == 0 and checkHorisontal(y, x):
			var wall_instance = moving_wall_x.instantiate();
	
			var adjusted_x = (x - x_offset) * 3 + 1.5
			var adjusted_z = (y - z_offset) * 3 + 1.5
			wall_instance.position = Vector3(adjusted_x, 6.5, adjusted_z)
			add_child(wall_instance)
			moving_walls_placed += 1


func checkHorisontal(y: int, x: int):
	if maze_layout[y][x - 1] == 0 && maze_layout[y + 1][x + 1] == 0 && maze_layout[y - 1][x - 1] == 0:
		maze_layout[y][x - 1] == 1
		return true;


func checkVertical(y: int, x: int):
	if maze_layout[y - 1][x] == 0 && maze_layout[y + 1][x - 1] == 0 && maze_layout[y + 1][x - 1] == 0:
		return true;

func add_monster():
		# Center position in (maze coordinates)
	var center_x = maze_width / 2
	var center_y = maze_height / 2
	
	# Convert 2D position to 3D position
	var adjusted_x = (center_x - x_offset) * 3 + 1.5
	var adjusted_z = (center_y - z_offset) * 3 + 1.5
	
	# Instantiate the Minotaur
	var monster = monster_scene.instantiate()
	monster.position = Vector3(adjusted_x, 1.5, adjusted_z)
	monster.scale = Vector3(0.016, 0.016, 0.016)
	
	# Add the Minotaur to the scene
	add_child(monster)
