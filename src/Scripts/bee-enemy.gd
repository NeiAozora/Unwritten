extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var speed: float = 5.0
@export var active_radius: float = 15.0
@export var attack_radius: float = 2.0
@export var damage_amount: float = 10.0
@export var attack_cooldown: float = 1.5
@export var max_health: float = 50.0
@export var target_group: String = "player"
@export var anim_player_path: NodePath = "bee2/AnimationPlayer" 

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = get_node_or_null(anim_player_path)

var health: float
var target: Node3D
var attack_timer: float = 0.0

func _ready():
	health = max_health
	# Wait for the first physics frame to sync navigation map
	await get_tree().physics_frame
	
	if not target:
		target = get_tree().get_first_node_in_group(target_group)

func _physics_process(delta):
	if attack_timer > 0:
		attack_timer -= delta
	
	# Always apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not target:
		target = get_tree().get_first_node_in_group(target_group)
		# Apply gravity even when no target
		move_and_slide()
		return
	
	var dist_to_target = global_position.distance_to(target.global_position)
	
	# 1. Check Active Radius
	if dist_to_target > active_radius:
		# Too far, stay idle
		play_anim("idlewalk")
		# Keep gravity, zero XZ movement
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
	
	# 2. Check Attack Radius
	if dist_to_target <= attack_radius:
		# Attack!
		play_anim("attack_001")
		look_at_target(target.global_position)
		# Keep gravity, zero XZ movement
		velocity.x = 0
		velocity.z = 0
		
		# Damage validation
		if attack_timer <= 0:
			deal_damage()
			attack_timer = attack_cooldown
		
		move_and_slide()
		return
	
	# 3. Chase (Navigation)
	play_anim("idlewalk")
	
	# Update navigation target
	nav_agent.target_position = target.global_position
	
	if nav_agent.is_navigation_finished():
		# Still apply gravity when navigation finished
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
	
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	# Only use horizontal direction (XZ plane)
	direction.y = 0
	direction = direction.normalized()
	
	# Set horizontal velocity, let gravity handle Y
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	# velocity.y is already handled by gravity above
	
	look_at_target(next_path_position)
	move_and_slide()

func deal_damage():
	if target.has_node("Model"):
		var model = target.get_node("Model")
		if model.has_node("Resources"):
			var resources = model.get_node("Resources")
			if resources.has_method("lose_health"):
				print("Bee dealing damage to player!")
				resources.lose_health(damage_amount)
	else:
		print("Target does not have expected Model/Resources structure")

func look_at_target(target_pos: Vector3):
	var look_pos = target_pos
	look_pos.y = global_position.y # Keep horizontal rotation only
	if global_position.distance_squared_to(look_pos) > 0.1:
		look_at(look_pos, Vector3.UP)

func play_anim(anim_name: String):
	if anim_player and anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func lose_health(amount: float):
	health -= amount
	print("Bee took damage! Remaining: ", health)
	if health <= 0:
		die()

func die():
	print("Bee died!")
	queue_free()

func hit(hit_data):
	if hit_data and "damage" in hit_data:
		print("Bee hit! Damage: ", hit_data.damage)
		lose_health(hit_data.damage)
