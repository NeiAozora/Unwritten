extends Area3D

# Simple Hurtbox for non-humanoid enemies
# Detects weapons and notifies parent to take damage

@export var processor: Node
@export var ignored_weapon_groups: Array[String] = ["enemy_weapon"]

func _ready():
	# Ensure monitoring is enabled
	monitoring = true
	monitorable = true
	print("BeeHurtbox ready! Processor: ", processor)

func _physics_process(delta):
	var areas = get_overlapping_areas()
	if areas.size() > 0:
		for area in areas:
			print("BeeHurtbox detected area: ", area.name, " is_attacking: ", "is_attacking" in area and area.is_attacking)
			_on_area_contact(area)

func _on_area_contact(area: Area3D):
	if _is_eligible_attacking_weapon(area):
		if not area.hitbox_ignore_list.has(self):
			area.hitbox_ignore_list.append(self)
			
			var hit_data = area.get_hit_data() if area.has_method("get_hit_data") else null
			print("BeeHurtbox: Got hit_data: ", hit_data, " damage: ", hit_data.damage if hit_data else "null")
			
			if processor and processor.has_method("hit"):
				processor.hit(hit_data)
			elif processor and processor.has_method("lose_health") and hit_data:
				processor.lose_health(hit_data.damage)

func _is_eligible_attacking_weapon(area: Area3D) -> bool:
	for group in ignored_weapon_groups:
		if area.is_in_group(group):
			return false
	
	if "is_attacking" in area and area.is_attacking:
		return true
		
	return false

