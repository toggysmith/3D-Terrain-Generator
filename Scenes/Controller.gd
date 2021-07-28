extends ClippedCamera

const MOUSE_SENSITIVITY = 0.5
const LOOK_ANGLE_LIMIT = 80
const NORMAL_MOVEMENT_SPEED = 100.0
const FAST_MOVEMENT_SPEED = NORMAL_MOVEMENT_SPEED * 4

var movement_amount = NORMAL_MOVEMENT_SPEED

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y += -event.relative.x * MOUSE_SENSITIVITY
		rotation_degrees.x += -event.relative.y * MOUSE_SENSITIVITY
		
		if rotation_degrees.x > LOOK_ANGLE_LIMIT:
			rotation_degrees.x = LOOK_ANGLE_LIMIT
		elif rotation_degrees.x < -LOOK_ANGLE_LIMIT:
			rotation_degrees.x = -LOOK_ANGLE_LIMIT

func handle_toggle_free_mouse():
	if Input.is_action_just_pressed("toggle_free_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_toggle_fast_move():
	if Input.is_action_just_pressed("toggle_fast_move"):
		movement_amount = FAST_MOVEMENT_SPEED
	elif Input.is_action_just_released("toggle_fast_move"):
		movement_amount = NORMAL_MOVEMENT_SPEED

func handle_relative_movement(delta):
	var backward_direction = transform.basis.z
	var right_direction = transform.basis.x
	
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	
	
	var movement_vector = (backward_direction * input_vector.y + right_direction * input_vector.x).normalized() * movement_amount
	
	
	translation += movement_vector * delta

func handle_vertical_movement(delta):
	var input_amount = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	translation.y -= input_amount * movement_amount * delta

func _physics_process(delta):
	handle_toggle_free_mouse()
	handle_toggle_fast_move()
	handle_relative_movement(delta)
	handle_vertical_movement(delta)
