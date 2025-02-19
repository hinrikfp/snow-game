extends Node

@export var day_length_s = 600;

var start_time_ms;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time_ms = Time.get_ticks_msec();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
