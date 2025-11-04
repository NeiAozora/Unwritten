extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 8

@onready var cameraBase = $cameraBase

func _ready() -> void:
	Input.mouse_mode = 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cameraBase.rotation.x = deg_to_rad(event.relative.y * 1)
		cameraBase.rotation.x = clamp(cameraBase.rotation.x, deg_to_rad(-45), deg_to_rad(45))
		rotation.y -= deg_to_rad(event.relative.x * 1)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("kiri", "kanan", "depan", "belakang")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
