extends AnimatableBody3D

@export var amplitude: float = 2.0
@export var speed: float = 2.0

var start_y: float
var target_y: float

func _ready():
	start_y = global_position.y
	target_y = start_y

func activate():
	target_y = start_y + amplitude

func deactivate():
	target_y = start_y

func _physics_process(delta):
	# Move smoothly towards target_y
	var new_y = move_toward(global_position.y, target_y, speed * delta)
	global_position.y = new_y
