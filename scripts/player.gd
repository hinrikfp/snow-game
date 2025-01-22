extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D

# RayCasts
@onready var ray_cast_camera: RayCast3D = $"Camera3D/RayCast-Camera"
@onready var ray_cast_down_back: RayCast3D = $"RayCast-Down-Back"
@onready var ray_cast_down_front: RayCast3D = $"RayCast-Down-Front"
@onready var ray_cast_front_bottom: RayCast3D = $"RayCast-Front-Bottom"
@onready var ray_cast_front_top: RayCast3D = $"RayCast-Front-Top"


@export var walk_speed: float = 4.0;
@export var run_speed: float = 7.0;
@export var jump_velocity: float = 4.5;

@export var sens_horizontal: float = 0.35;
@export var sens_vertical: float = 0.5;

@export var base_fov := 75.0;
@export var run_fov_change := 1.5;

var speed: float = walk_speed;

func can_climb() -> bool:
	if !ray_cast_front_top.is_colliding() || !ray_cast_front_bottom.is_colliding():
		return false;
	var top_dist = ray_cast_front_top.global_transform.origin.distance_to(ray_cast_front_top.get_collision_point())
	var bottom_dist = ray_cast_front_bottom.global_transform.origin.distance_to(ray_cast_front_bottom.get_collision_point())
	if top_dist < 1.5 && bottom_dist < 1.5:
		return true
	return false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90.0), deg_to_rad(60.0))
	
	if event.is_action_pressed("ui_cancel") && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_pressed("run"):
		speed = run_speed
		camera.fov = base_fov + run_fov_change
	else:
		speed = walk_speed
		camera.fov = base_fov

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
