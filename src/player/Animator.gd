extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	parent.connect("walk_forward", self, "walk_forward_animation")
	parent.connect("walk_left", self, "walk_left_animation")
	parent.connect("walk_right", self, "walk_right_animation")
	parent.connect("idle", self, "idle_animation")


func walk_forward_animation():
	play("walk_forward")

func walk_right_animation():
	play("walk_right")

func walk_left_animation():
	play("walk_left")

func idle_animation():
	play("Idle")
