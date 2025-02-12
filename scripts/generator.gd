extends StaticBody3D

signal generator_started()

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

enum GeneratorState {
	Broken,
	Fixed,
	Running,
}

var generator_state: GeneratorState = GeneratorState.Broken

func interact(player: Player) -> void:
	if generator_state == GeneratorState.Broken:
		if player.inventory.get("parts") >= 1:
			generator_state = GeneratorState.Fixed
	elif generator_state == GeneratorState.Fixed:
		audio_stream_player_3d.play(0)
		generator_state = GeneratorState.Running
	elif generator_state == GeneratorState.Running:
		audio_stream_player_3d.stream_paused = true
		generator_state = GeneratorState.Fixed

func get_generator_state() -> GeneratorState:
	return self.generator_state
