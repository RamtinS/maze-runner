extends Node

var next_scene: String = "res://Levels/Playground.tscn"
var resource_loader = ResourceLoader

@onready var progress_bar = $CanvasLayer/CenterContainer/GridContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resource_loader.load_threaded_request(next_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress = []
	resource_loader.load_threaded_get_status(next_scene, progress)
	progress_bar.value = progress[0]*100
	
	if progress[0] == 1:
		var packed_scene = resource_loader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
