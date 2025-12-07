extends AnimatableBody3D

enum MoveAxis { X, Z }

@export var movement_axis: MoveAxis = MoveAxis.X
@export var amplitude: float = 2.0
@export var speed: float = 2.0

var start_pos: float
var target_pos: float

func _ready():
	# Ambil posisi awal saat game mulai
	if movement_axis == MoveAxis.X:
		start_pos = global_position.x
	else:
		start_pos = global_position.z
	
	target_pos = start_pos
	
	# Set to true to ensure CharacterBody3D moves with the platform
	sync_to_physics = true

func activate():
	target_pos = start_pos + amplitude

func deactivate():
	target_pos = start_pos

func _physics_process(delta):
	if movement_axis == MoveAxis.X:
		var new_x = move_toward(global_position.x, target_pos, speed * delta)
		global_position.x = new_x
	else:
		var new_z = move_toward(global_position.z, target_pos, speed * delta)
		global_position.z = new_z
