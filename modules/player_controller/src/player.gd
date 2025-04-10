extends CharacterBody3D

const GRAVITY = -64.0
const MOVE_SPEED = 5.0
const MOUSE_SENSITIVITY = 0.3

@onready var x_axis = $X
@onready var y_axis = $X/Y

var mouse_move_dir: Vector2
var is_using = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func process_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += Vector3(0.0, GRAVITY, 0.0) * delta

func process_input(delta: float) -> void:
	var input = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input.y += 1.0
	if Input.is_action_pressed("move_back"):
		input.y -= 1.0
	if Input.is_action_pressed("move_right"):
		input.x += 1.0
	if Input.is_action_pressed("move_left"):
		input.x -= 1.0
	input = input.normalized()
	var forward = -x_axis.global_transform.basis.z
	var right = x_axis.global_transform.basis.x
	var move_dir = Vector3.ZERO
	move_dir += right * input.x
	move_dir += forward * input.y
	move_dir *= MOVE_SPEED
	velocity += move_dir

func process_mouse_look(delta: float) -> void:
	mouse_move_dir *= delta
	x_axis.rotate_y(-mouse_move_dir.x * MOUSE_SENSITIVITY)
	y_axis.rotate_x(-mouse_move_dir.y * MOUSE_SENSITIVITY)
	mouse_move_dir = Vector2.ZERO

func process_movement(delta: float) -> void:
	velocity = Vector3.ZERO
	process_gravity(delta)
	process_input(delta)
	move_and_slide()

func process_use_input() -> void:
	if Input.is_action_just_pressed("use"):
		is_using = true

func process_use() -> void:
	if not is_using:
		return
	is_using = false
	
	var ray_origin = y_axis.global_position 
	var ray_forward = -y_axis.global_transform.basis.z
	ray_origin += ray_forward * 0.5
	var ray_end = ray_origin + (ray_forward * 2.0)
	var space_state = get_world_3d().direct_space_state
	var ray_param = PhysicsRayQueryParameters3D.new()
	ray_param.from = ray_origin
	ray_param.to = ray_end
	var ray = space_state.intersect_ray(ray_param)
	if ray:
		var obj = ray.collider
		if is_instance_valid(obj):
			obj.call("use")

func _process(delta: float) -> void:
	process_mouse_look(delta)
	process_use_input()

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_use()

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_move_dir += event.relative
