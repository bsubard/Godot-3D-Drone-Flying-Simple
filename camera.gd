extends Node3D

@export var mouse_sensitivity: float = 0.002
@export var follow_speed: float = 5.0
@export var height_offset: float = 2.0
@export var distance_offset: float = 5.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var player: CharacterBody3D
var mouse_delta: Vector2 = Vector2.ZERO

func _ready():
	# Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Find the player node (assuming it's a sibling)
	player = get_parent().get_node("Player")  # Adjust path as needed
	
	# Set up spring arm
	if spring_arm:
		spring_arm.spring_length = distance_offset
		spring_arm.collision_mask = 1  # Adjust collision mask as needed

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _process(delta):
	if not player:
		return
	
	handle_mouse_look(delta)
	follow_player(delta)
	update_player_rotation()

func handle_mouse_look(delta):
	if mouse_delta.length() > 0:
		# Rotate horizontally (Y axis)
		rotate_y(-mouse_delta.x * mouse_sensitivity)
		
		# Rotate vertically (X axis) - limit the range
		var current_x_rotation = spring_arm.rotation.x
		var new_x_rotation = current_x_rotation - mouse_delta.y * mouse_sensitivity
		new_x_rotation = clamp(new_x_rotation, deg_to_rad(-80), deg_to_rad(80))
		spring_arm.rotation.x = new_x_rotation
		
		mouse_delta = Vector2.ZERO

func follow_player(delta):
	if player:
		# Follow player position with offset
		var target_position = player.global_position + Vector3(0, height_offset, 0)
		global_position = global_position.lerp(target_position, follow_speed * delta)

func update_player_rotation():
	# Tell the player which direction is "forward" based on camera Y rotation
	if player and player.has_method("set_y_rotation"):
		player.set_y_rotation(global_rotation.y)

func _unhandled_input(event):
	# Toggle mouse capture with Escape key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
