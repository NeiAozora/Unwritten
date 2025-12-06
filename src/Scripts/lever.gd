extends Node3D

# Pastikan path ini benar. Kalau error "null", drag node AnimationPlayer ke sini.
@onready var anim = $AnimationPlayer 

func _ready():
	# Cek dulu biar gak crash
	if not anim:
		print("ERROR: AnimationPlayer tidak ditemukan!")
		return

	# Hubungkan signal: Saat animasi selesai -> panggil fungsi _on_anim_finished
	anim.animation_finished.connect(_on_anim_finished)
	
	# Mulai loop dengan animasi pertama
	print("Mulai Debug Auto-Loop...")
	anim.play("turn_on")

# Fungsi ini otomatis dipanggil setiap kali animasi selesai
func _on_anim_finished(anim_name):
	if anim_name == "turn_on":
		# Kalau baru selesai ON, jalankan OFF
		print("Selesai ON -> Menuju OFF")
		anim.play("turn_off")
		
	elif anim_name == "turn_off":
		# Kalau baru selesai OFF, jalankan ON lagi
		print("Selesai OFF -> Menuju ON")
		anim.play("turn_on")
