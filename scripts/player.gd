extends CharacterBody3D
class_name Player

@onready var camera: Camera3D = $Camera3D

# RayCasts
@onready var ray_cast_camera: RayCast3D = $"Camera3D/RayCast-Camera"
@onready var ray_cast_down_back: RayCast3D = $"RayCast-Down-Back"
@onready var ray_cast_down_front: RayCast3D = $"RayCast-Down-Front"
@onready var ray_cast_front_bottom: RayCast3D = $"RayCast-Front-Bottom"
@onready var ray_cast_front_top: RayCast3D = $"RayCast-Front-Top"
@onready var ui: UI = $"../UI"


@export var walk_speed: float = 3.0;
@export var run_speed: float = 6.0;
@export var jump_velocity: float = 4.5;
@export var min_climb_angle: float = 45.0;

@export var sens_horizontal: float = 0.35;
@export var sens_vertical: float = 0.5;

@export var base_fov := 75.0;
@export var run_fov_change := 1.5;

@export var max_health: int = 100;
@export var max_stamina: float = 10;

class Result:
	var ok: bool;
	var result;
	func _init(ok_v: bool, result_v):
		ok = ok_v
		result = result_v
		

var health: int;
var stamina: float;

@export var inventory: Dictionary = {
	"wood": 0,
	"parts": 0,
};

var speed: float = walk_speed;

var is_in_warmth: bool = false;

var warmth_last_tick: float = 0;

enum PlayerMovement {
	Idle,
	Walking,
	Running,
	Jumping,
	Falling,
	Sliding,
	Climbing,
}

var player_movement := PlayerMovement.Idle;

@export var fireplace: Fireplace;

# callbacks

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	health = max_health
	health -= 50
	stamina = max_stamina
	ui.set_health_label(health)
	

func _input(event: InputEvent) -> void: #{
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90.0), deg_to_rad(60.0))
	
	if event.is_action_pressed("ui_cancel") && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton && Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("climb") && climb_slope() > min_climb_angle:
		player_movement = PlayerMovement.Climbing
		velocity = Vector3.ZERO
	
	if event.is_action_pressed("interact"):
		process_interact()
#}

func _physics_process(delta: float) -> void: #{
	if player_movement == PlayerMovement.Climbing:
		if climb_slope() <= min_climb_angle:
			player_movement = PlayerMovement.Idle
		else:
			process_climbing(delta)
	else:
		process_movement(delta)
	var focus = check_focus()
	if focus.ok:
		ui.set_interactable_label(focus.result)
	else:
		ui.set_interactable_label("")

	if Time.get_ticks_msec() - warmth_last_tick >= 2000.0 && is_in_warmth:
		if fireplace.fire_lit:
			change_health(+5)
		else:
			change_health(+1)
		warmth_last_tick = Time.get_ticks_msec()
#}

# signals

func _on_cabin_warmth_body_entered(body: Node3D) -> void:
	if body == self:
		is_in_warmth = true
		warmth_last_tick = Time.get_ticks_msec()

func _on_cabin_warmth_body_exited(body: Node3D) -> void:
	if body == self:
		is_in_warmth = false
		warmth_last_tick = 0.0

func _on_tree_got_wood(amount: int) -> void:
	inventory["wood"] += 1
	print(inventory["wood"])
	
func _on_plane_got_parts() -> void:
	inventory["parts"] += 1

# functions

func can_climb() -> bool: #{
	if !ray_cast_front_top.is_colliding() || !ray_cast_front_bottom.is_colliding():
		return false
	var top_dist = ray_cast_front_top.global_transform.origin.distance_to(ray_cast_front_top.get_collision_point())
	var bottom_dist = ray_cast_front_bottom.global_transform.origin.distance_to(ray_cast_front_bottom.get_collision_point())
	if top_dist < 1.5 && bottom_dist < 1.5:
		return true
	return false
#}

func climb_slope() -> float: #{
	if !ray_cast_front_top.is_colliding() || !ray_cast_front_bottom.is_colliding():
		return 0.0
	var top_dist = ray_cast_front_top.global_transform.origin.distance_to(ray_cast_front_top.get_collision_point())
	var bottom_dist = ray_cast_front_bottom.global_transform.origin.distance_to(ray_cast_front_bottom.get_collision_point())
	var top_to_bottom = ray_cast_front_top.global_transform.origin.y - ray_cast_front_bottom.global_transform.origin.y
	var dist_diff = abs(top_dist - bottom_dist)
	var angle = 90 - rad_to_deg(atan(dist_diff / top_to_bottom))
	if top_dist < bottom_dist:
		angle = -angle
	return angle
#}

func get_surface_rotation() -> Transform3D:
	var up = Vector3.UP
	var wall_normal = ray_cast_front_top.get_collision_normal()
	var wall_tangent = wall_normal.cross(up).normalized()
	var wall_up = wall_normal.cross(wall_tangent).normalized()
	
	return Transform3D(Basis(wall_tangent, wall_up, wall_normal), Vector3.ZERO)

func process_climbing(delta: float) -> void: #{
	if Input.is_action_just_pressed("crouch"):
		player_movement = PlayerMovement.Idle
		return
	var input_dir := Input.get_vector("right", "left", "forward", "backward")
	var direction := (Vector3(input_dir.x, input_dir.y, 0)).normalized()
	if direction:
		velocity = (get_surface_rotation() * direction) * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	var to_wall := -get_surface_rotation().basis.z
	to_wall.y = 0
	velocity += to_wall * 5
	move_and_slide()
#}

func process_movement(delta: float) -> void: #{
	# Add the gravity.
	if not is_on_floor() && player_movement != PlayerMovement.Climbing:
		velocity += get_gravity() * delta
		if velocity.y < 0:
			player_movement = PlayerMovement.Falling

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		player_movement = PlayerMovement.Jumping
	
	if Input.is_action_pressed("run"):
		speed = run_speed
		camera.fov = base_fov + run_fov_change
		if is_on_floor():
			player_movement = PlayerMovement.Running
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
		if player_movement != PlayerMovement.Running && is_on_floor():
			player_movement = PlayerMovement.Walking
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if velocity.is_zero_approx() && player_movement != PlayerMovement.Climbing:
		player_movement = PlayerMovement.Idle
	
	move_and_slide()
#}

func process_interact() -> bool:
	if ray_cast_camera.is_colliding():
		var collider: Node = ray_cast_camera.get_collider()
		if collider.is_in_group("interactable"):
			collider.call("interact", self)
			return true
	return false

func check_focus() -> Result:
	if ray_cast_camera.is_colliding():
		var collider: Node = ray_cast_camera.get_collider()
		if collider.is_in_group("interactable") && collider.has_method("get_focus_message"):
			var focus_message = collider.call("get_focus_message")
			return Result.new(true, focus_message)
	return Result.new(false, "")

func get_inventory() -> Dictionary:
	return self.inventory


func change_health(amount: int) -> void:
	self.health = clamp(self.health + amount, 0, max_health)
	ui.set_health_label(self.health)
