extends KinematicBody

export(bool) var DEBUG : bool = false


const DEBUG_FLY_SPEED : int = 7
const DEBUG_FLY_SPRINT : float = 2.0
const DEBUG_FLY_SLOW : float = 0.5

 
const CROUCH_MULTIPLIER : float = 0.25
const SPRINT_MULTIPLIER : float = 2.0
const ACCELERATION : int = 20
const WALK_SPEED : int = 12
const JUMP_FORCE : int = 42

var first_person_position = Vector3(0, 0, 0)
var third_person_position = Vector3(0, 3, -12)

var GRAVITY : float = 98
var mouse_sensitivity : float = 0.1

var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var fall : Vector3 = Vector3()

var mouse_captured : bool = true
var first_person_mode : bool = true

var headbone : int
var initial_headbone_transform : Transform

onready var skeleton = $CollisionShape/Model/Armature/Skeleton
onready var head = $Head
onready var animator = $AnimationPlayer
onready var first_person_camera = $Head/FirstPersonCamera
onready var third_person_camera = $Head/ThirdPersonCamera

signal idle
signal walk_forward
signal walk_left
signal walk_right
signal jump
signal sprint
signal crouch


func _ready():
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
	
	if event.is_action_pressed("debug_movement_switch"):
		DEBUG = !DEBUG
	
	# Allows the player to look arround the scene regardless of the camera
	handle_looking(event)


func _physics_process(delta):
	if not Input.is_action_pressed("debug_movement_switch") and DEBUG:
		# Godot like movement for debugging
		debug_movement(delta)
		return
	
	# Normal player movement
	handle_movement(delta)


func handle_movement(delta):
	var normalized_direction = Vector3()
	var direction = Vector3()
	var movement_multiplier = 1
	
	if !is_on_floor():
		fall.y -= GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = JUMP_FORCE
	
	
	if Input.is_action_pressed("walk_forward"):
		direction -= transform.basis.z
		normalized_direction = Vector3(0, 0, 1)
	
	elif Input.is_action_pressed("walk_backward"):
		direction += transform.basis.z
		normalized_direction = Vector3(0, 0, -1)
	
	if Input.is_action_pressed("walk_left"):
		direction -= transform.basis.x
		normalized_direction = Vector3(1, 0, 0)
	
	elif Input.is_action_pressed("walk_right"):
		direction += transform.basis.x
		normalized_direction = Vector3(-1, 0, 0)
	
	if Input.is_action_pressed("sprint"):
		movement_multiplier = SPRINT_MULTIPLIER
	
	if Input.is_action_pressed("crouch"):
		movement_multiplier = CROUCH_MULTIPLIER
	
	animator.playback_speed = movement_multiplier
	
	#play_animation(normalized_direction)
	handle_movement_state(normalized_direction)
	
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(-direction*WALK_SPEED*movement_multiplier, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	move_and_slide(fall, Vector3.UP)


func handle_movement_state(dir):
	if dir == Vector3.ZERO and animator.current_animation != "Idle":
		emit_signal("idle")
		return
	
	# lazy animations just to get things going around here
	if (dir.z > 0 or dir.z < 0) and animator.current_animation != "walk_forward":
		emit_signal("walk_forward")
		
	if dir.x < 0 and animator.current_animation != "walk_right":
		emit_signal("walk_right")
	
	if dir.x > 0 and animator.current_animation != "walk_left":
		emit_signal("walk_left")


#func play_animation(dir):
#	if dir.z > 0 and animator.current_animation != "walk_forward":
#		animator.play("walk_forward")
#	if dir.z < 0 and animator.current_animation != "walk_forward":
#		animator.play_backwards("walk_forward")
#
#	if dir.x < 0 and animator.current_animation != "walk_right":
#		animator.play("walk_right")
#	if dir.x < 0 and animator.current_animation != "walk_right":
#		animator.play_backwards("walk_right")
#
#	if dir.x > 0 and animator.current_animation != "walk_left":
#		animator.play("walk_left")
#	if dir.x > 0 and animator.current_animation != "walk_left":
#		animator.play_backwards("walk_left")
#
#	if dir == Vector3.ZERO and animator.current_animation != "Idle":
#		animator.play("Idle")


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


func debug_movement(delta):
	if !mouse_captured:
		return
	
	var normalized_direction = Vector3()
	var direction = Vector3()
	var movement_multiplier = 1
	
	var flying = false
	
	if Input.is_action_pressed("toggle_fly"):
		flying = true
	
	if !is_on_floor() and not flying:
		fall.y -= GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and not flying:
		fall.y = JUMP_FORCE
	
	
	if Input.is_action_pressed("walk_forward"):
		direction -= transform.basis.z
		normalized_direction = Vector3(0, 0, 1)
	
	elif Input.is_action_pressed("walk_backward"):
		direction += transform.basis.z
		normalized_direction = Vector3(0, 0, -1)
	
	if Input.is_action_pressed("walk_left"):
		direction -= transform.basis.x
		normalized_direction = Vector3(1, 0, 0)
	
	elif Input.is_action_pressed("walk_right"):
		direction += transform.basis.x
		normalized_direction = Vector3(-1, 0, 0)
	
	if Input.is_action_pressed("sprint"):
		movement_multiplier = SPRINT_MULTIPLIER
	
	if Input.is_action_pressed("crouch"):
		movement_multiplier = CROUCH_MULTIPLIER
	
	animator.playback_speed = movement_multiplier
	
	#play_animation(normalized_direction)
	handle_movement_state(normalized_direction)
	
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(-direction*WALK_SPEED*movement_multiplier, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	move_and_slide(fall, Vector3.UP)


func toggle_character_view():
	first_person_mode = !first_person_mode
	
	if first_person_mode:
		third_person_camera.current = false
		first_person_camera.current = true
	else:
		first_person_camera.current = false
		third_person_camera.current = true

