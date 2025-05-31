extends Node

const MAX_COINS: int = 50
var collected_coins: int = 0
var time_passed: float = 0.0
var time_running: bool = false

func update_coins(coins: int) -> void:
	collected_coins += coins

func set_time_passed(time: float) -> void:
	time_passed = time

func get_max_coins() -> int:
	return MAX_COINS
	
func get_collected_coins() -> int:
	return collected_coins

func get_time() -> String:
	var total_seconds = int(time_passed)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func get_time_in_float() -> float:
	return round(time_passed * 10000) / 10000.0

# Start the timer
func start_timer() -> void:
	time_running = true

# Stop the timer
func stop_timer() -> void:
	time_running = false

# Reset all stats (coins and time)
func reset_stats() -> void:
	collected_coins = 0
	time_passed = 0.0
	time_running = false

# Update the timer, to be called every frame
func update_timer(delta: float) -> void:
	if time_running:
		time_passed += delta
