extends KinematicBody

export(bool) var DEBUG : bool = true


const DEBUG_FLY_SPEED : int = 12
const DEBUG_FLY_SPRINT : float = 2.0
const DEBUG_FLY_SLOW : float = 0.5

const ACCELERATION : int = 6
const WALK_SPEED : int = 12
const JUMP_FORCE : int = 42
const CROUCH_MULTIPLIER : float = 0.25
const SPRINT_MULTIPLIER : float = 2.0

var GRAVITY : float = 98
var mouse_sensitivity : float = 0.1

var double_input_allowed = false


var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var fall : Vector3 = Vector3()
var movement_multiplier : float = 1
var fly_multiplier : float = 1

var flying : bool = true

var mouse_captured : bool = true
var first_person_mode : bool = true


onready var head = $Head
onready var first_person_camera = $Head/FirstPersonCamera
onready var third_person_camera = $Head/ThirdPersonCamera
onready var double_input_timer = $DoubleInputTimer

func _ready():
	double_input_timer.connect("timeout", self, "double_input_timeout")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event.is_action_pressed("toggle_mouse_mode"):
		mouse_captured = !mouse_captured
		
		if !mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	if event.is_action_pressed("toggle_character_view"):
		toggle_character_view()
	
	if event.is_action_pressed("toggle_debug_mode"):
		DEBUG = !DEBUG
		print("Debug mode: " + str(DEBUG))
	
	# Allows the player to look arround the scene using any camera (First or third person camera)
	handle_looking(event)


func _physics_process(delta):
	handle_movement(delta)


func handle_looking(event):
	if !mouse_captured:
		return
	
	var camera
	
	if first_person_mode:
		camera = first_person_camera
	else:
		camera = third_person_camera
	
	if event is InputEventMouseMotion:
		if first_person_mode:
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			camera.rotation.x -= deg2rad(event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg2rad(-90), deg2rad(90))
		else:
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			head.rotate_x(deg2rad(event.relative.y * mouse_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))


func handle_movement(delta):	
	_calculate_movement_direction()
	_calculate_movement_multiplier()
	_calculate_fall_vector(delta)
	
	_move(delta)


func _calculate_movement_direction():
	direction = Vector3()
	
	if Input.is_action_pressed("walk_forward"):
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("walk_backward"):
		direction += transform.basis.z
	
	if Input.is_action_pressed("walk_left"):
		direction -= transform.basis.x
	
	elif Input.is_action_pressed("walk_right"):
		direction += transform.basis.x


func _calculate_fall_vector(delta):
	if DEBUG:
		if flying:
			fly_multiplier = 1
			fall = Vector3()
		
		if Input.is_action_just_pressed("jump"):
			if double_input_allowed:
				flying = !flying
				print("Flying: " + str(flying))
				return
			
			double_input_timer.start()
			double_input_allowed = true
		
		
		if Input.is_action_pressed("sprint") and flying:
			fly_multiplier = 2
	
	
	if !is_on_floor() and not flying:
		fall.y -= GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not flying:
		fall.y = JUMP_FORCE
	
	if Input.is_action_pressed("jump") and flying:
		fall.y += DEBUG_FLY_SPEED * fly_multiplier
	
	if Input.is_action_pressed("crouch") and flying:
		fall.y -= DEBUG_FLY_SPEED * fly_multiplier
	
	if Input.is_action_pressed("crouch") and is_on_floor() and flying:
		flying = !flying


func _calculate_movement_multiplier():
	movement_multiplier = 1
	
	if Input.is_action_pressed("sprint"):
		movement_multiplier = SPRINT_MULTIPLIER
	
	if Input.is_action_pressed("crouch"):
		movement_multiplier = CROUCH_MULTIPLIER


func _move(delta):
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(-direction*WALK_SPEED*movement_multiplier, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# warning-ignore:return_value_discarded
	move_and_slide(fall, Vector3.UP)


func double_input_timeout():
	double_input_allowed = false


func toggle_character_view():
	first_person_mode = !first_person_mode
	
	if first_person_mode:
		third_person_camera.current = false
		first_person_camera.current = true
	else:
		first_person_camera.current = false
		third_person_camera.current = true

