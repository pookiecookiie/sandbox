extends KinematicBody

var mouse_sensitivity = 0.3
var camera_angle = 0

var velocity : Vector3 = Vector3()
var direction : Vector3 = Vector3()

const FLY_SPEED = 40
const FLY_ACC = 4

func _input(event):
	if !get_tree().get_root().get_node("main").focused:
		return
	
	if event is InputEventMouseMotion:
		$Head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change


func _physics_process(delta):
	if !get_tree().get_root().get_node("main").focused:
		return
	
	direction = Vector3()
	
	var aim = $Head/Camera.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
		
	
	direction = direction.normalized()
	var target = direction * FLY_SPEED
	velocity = velocity.linear_interpolate(target, FLY_ACC * delta)
	move_and_slide(velocity)

