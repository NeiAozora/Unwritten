extends AnimatableBody3D

@export var amplitude: float = 2.0
@export var speed: float = 2.0

var start_y: float
var target_y: float
var moving_up: bool = true # Status arah gerakan

func _ready():
	start_y = global_position.y
	# Set target awal langsung ke atas
	target_y = start_y + amplitude

func _physics_process(delta):
	# 1. Gerakkan objek menuju target
	var new_y = move_toward(global_position.y, target_y, speed * delta)
	global_position.y = new_y
	
	# 2. Cek apakah sudah sampai di target
	if is_equal_approx(global_position.y, target_y):
		# Jika sampai, balik arahnya
		moving_up = !moving_up
		
		# Tentukan target baru berdasarkan arah
		if moving_up:
			target_y = start_y + amplitude
		else:
			target_y = start_y
