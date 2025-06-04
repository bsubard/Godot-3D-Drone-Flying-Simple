extends CharacterBody3D

@export var thrust_power: float = 15.0
@export var tilt_speed: float = 2.0
@export var max_tilt_angle: float = 45.0
@export var movement_speed: float = 8.0
@export var sprint_multiplier: float = 2.0
@export var drag: float = 0.95
@export var angular_drag: float = 0.9
@export var propeller_speed: float = 20.0  # Rotations per second

var target_rotation: Vector3 = Vector3.ZERO
var thrust_input: float = 0.0

# Propeller references
@onready var propeller1: MeshInstance3D = $MeshInstance3D
@onready var propeller2: MeshInstance3D = $MeshInstance3D2
@onready var propeller3: MeshInstance3D = $MeshInstance3D3
@onready var propeller4: MeshInstance3D = $MeshInstance3D4

func _ready():
	# Ensure we're affected by gravity
	pass

func _physics_process(delta):
	handle_input()
	apply_physics(delta)
	apply_rotation(delta)
	spin_propellers(delta)
	move_and_slide()

func handle_input():
	# Thrust (vertical movement)
	thrust_input = 0.0
	if Input.is_action_pressed("ui_accept"):  # Space bar - up
		thrust_input = thrust_power
	if Input.is_action_pressed("move_down"):  # Ctrl - down
		thrust_input = -thrust_power
	
	# Check for sprint modifier
	var current_speed = movement_speed
	if Input.is_action_pressed("sprint"):  # Shift key
		current_speed *= sprint_multiplier
	
	# Movement and tilting
	var input_vector = Vector2.ZERO
	target_rotation = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):  # W
		input_vector.y -= 1
		target_rotation.x = deg_to_rad(-max_tilt_angle)
	if Input.is_action_pressed("move_backward"):  # S
		input_vector.y += 1
		target_rotation.x = deg_to_rad(max_tilt_angle)
	if Input.is_action_pressed("move_left"):  # A
		input_vector.x -= 1
		target_rotation.z = deg_to_rad(max_tilt_angle)
	if Input.is_action_pressed("move_right"):  # D
		input_vector.x += 1
		target_rotation.z = deg_to_rad(-max_tilt_angle)
	
	# Apply movement based on input and current rotation
	if input_vector.length() > 0:
		var movement_direction = Vector3(input_vector.x, 0, input_vector.y)
		# Transform movement relative to current Y rotation (camera forward direction)
		movement_direction = movement_direction.rotated(Vector3.UP, global_rotation.y)
		velocity += movement_direction * current_speed * get_physics_process_delta_time()

func apply_physics(delta):
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.02
	
	# Apply thrust (upward force)
	velocity.y += thrust_input * delta
	
	# Apply drag to all movement
	velocity *= drag

func apply_rotation(delta):
	# Smoothly rotate towards target rotation
	rotation.x = lerp_angle(rotation.x, target_rotation.x, tilt_speed * delta)
	rotation.z = lerp_angle(rotation.z, target_rotation.z, tilt_speed * delta)
	
	# Apply angular drag to prevent infinite spinning
	var current_angular_velocity = Vector3(
		rotation.x - target_rotation.x,
		0,
		rotation.z - target_rotation.z
	)
	current_angular_velocity *= angular_drag

# Function to set Y rotation from camera (called by camera script)
func set_y_rotation(y_rot: float):
	rotation.y = y_rot

func spin_propellers(delta):
	# Spin all propellers - alternating directions for realism
	var spin_amount = propeller_speed * delta * TAU  # TAU = 2 * PI
	
	if propeller1:
		propeller1.rotation.y += spin_amount
	if propeller2:
		propeller2.rotation.y -= spin_amount  # Opposite direction
	if propeller3:
		propeller3.rotation.y += spin_amount
	if propeller4:
		propeller4.rotation.y -= spin_amount  # Opposite direction
