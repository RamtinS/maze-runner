extends Node

@onready var time_label = $CanvasLayer/HBoxContainer/TimeLabel
@onready var coin_label = $CanvasLayer/HBoxContainer/CoinLabel
@onready var health_bar = $CanvasLayer/HealthBar
@onready var player = get_node("../Maze/Player")

var time_passed: float = 0.0 
var time_running: bool = false

const MAX_COINS: int = 50
var collected_coins: int = 0

func _ready() -> void:	
	player = get_node("../Maze/Player")
	time_label.text = "00:00:00"
	coin_label.text = "0/%d" % MAX_COINS
	health_bar.max_value = player.get_max_health()
	start_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateHealth()
	if time_running: 
		time_passed += delta
		time_label.text = format_time(time_passed)
		PlayerStats.set_time_passed(time_passed)

func updateHealth() -> void:
	var current_health = player.get_health()  # Get player's current health
	health_bar.value = current_health  # Update the health bar value

func start_timer() -> void:
	time_running = true
	PlayerStats.start_timer()

func stop_timer() -> void:
	time_running = false
	PlayerStats.stop_timer()

func format_time(time_in_seconds: float) -> String:
	var total_seconds = int(time_in_seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func get_max_coins() -> int:
	return MAX_COINS

func get_collected_coins() -> int:
	return collected_coins	
	
func get_time() -> String:
	return format_time(time_passed)
	
func get_time_in_float() -> float:
	return time_passed
	
func update_coin_count(coin: int) -> void:
	collected_coins += coin
	coin_label.text = "%d/%d" % [collected_coins, MAX_COINS]
	PlayerStats.update_coins(coin)
	
	
