extends MeshInstance3D

@onready var player: CharacterBody3D = $"../../Player"

var shader_mat: ShaderMaterial;
var path_map_texture: ImageTexture;
var path_image: Image = Image.create(1000, 1000, false, Image.FORMAT_RGB8);

var last_time: float = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader_mat = self.get_active_material(0)
	shader_mat.set_shader_parameter("path_map", ImageTexture.create_from_image(path_image))
	last_time = Time.get_ticks_msec()
	print(path_image)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	path_map_texture = shader_mat.get_shader_parameter("path_map")
	var player_relative_pos: Vector2 = Vector2(player.position.x - position.x, player.position.z - position.z)
	var image_coord = Vector2i((player_relative_pos * 10.0).x + 500.0, (player_relative_pos * 10.0).y + 500.0)
	var brush_size = 5
	if (image_coord.x < 1000 && image_coord.y < 1000 && image_coord.x > 0 && image_coord.y > 0 && player.is_on_floor()):
		for x in range(-brush_size, brush_size):
			for y in range(-brush_size, brush_size):
				if (image_coord.x + x < 1000 && image_coord.y + y < 1000 && image_coord.x + x > 0 && image_coord.y + y > 0):
					var from_center: float = sqrt(pow(abs(x),2) + pow(abs(y),2))
					if from_center <= brush_size:
						var color: Color = Color(1.0 - (from_center/float(brush_size)), 0.0,0.0)
						path_image.set_pixelv(image_coord + Vector2i(x,y), color)
		if Time.get_ticks_msec() - last_time > 500.0:
			path_map_texture.update(path_image)
			last_time = Time.get_ticks_msec()
	if Input.is_key_pressed(KEY_F2):
		path_image.save_exr("path_map.exr", false)
	
	
	
