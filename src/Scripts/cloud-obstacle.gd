#extends Node3D
#
#@export var amplitude: float = 2.0   # Jarak naik-turun
#@export var speed: float = 2.0       # Kecepatan gerak
#
#var start_y: float
#
#func _ready():
	#start_y = position.y
#
#func _process(delta):
	#position.y = start_y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude

#extends AnimatableBody3D
#
#@export var amplitude: float = 2.0
#@export var speed: float = 2.0
#
#var start_y: float
#
#func _ready():
	#start_y = global_position.y
#
#func _physics_process(delta):
	#var t = Time.get_ticks_msec() / 1000.0
	#var target_y = start_y + sin(t * speed) * amplitude
	#
	## Gerakkan platform secara smooth tanpa teleport keras
	#global_position.y = lerp(global_position.y, target_y, 0.2)


extends AnimatableBody3D

@export var amplitude: float = 2.0
@export var speed: float = 2.0

var start_y: float
var time_passed: float = 0.0

func _ready():
	start_y = global_position.y

func _physics_process(delta):
	# Gunakan akumulator delta agar waktu sinkron dengan frame fisika
	time_passed += delta
	
	# Hitung posisi baru murni dari Sinus (Sinus sudah smooth secara matematika)
	var target_y = start_y + sin(time_passed * speed) * amplitude
	
	# Update posisi secara langsung.
	# AnimatableBody3D akan otomatis memberi tahu physics engine
	# bahwa object ini bergerak, sehingga pemain bisa "menempel".
	global_position.y = target_y
