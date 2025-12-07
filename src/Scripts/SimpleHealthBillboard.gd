@tool
extends Node3D

@export var target: Node3D
@export var show_distance: float = 10.0
@export var damage_delay: float = 0.5
@onready var bar: ProgressBar = $SubViewport/Control/ProgressBar
@onready var damage_bar: ProgressBar = $SubViewport/Control/DamageBar
@onready var value_label: Label = $SubViewport/Control/ProgressBar/Value

var damage_bar_target: float = 0.0

func _ready():
	# Match player HUD style: green fill with dark background.
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.12, 0.35, 0.12, 1) # Green
	fill.border_width_left = 1
	fill.border_width_top = 1
	fill.border_width_right = 1
	fill.border_width_bottom = 1
	fill.border_color = Color(0.05, 0.15, 0.05, 1)
	bar.add_theme_stylebox_override("fill", fill)
	var bg := fill.duplicate()
	bg.bg_color = Color(0.05, 0.08, 0.05, 0.8)
	bar.add_theme_stylebox_override("background", bg)
	
	# Setup damage bar style (darker red background)
	var damage_fill := StyleBoxFlat.new()
	damage_fill.bg_color = Color(0.6, 0.15, 0.15, 1) # Red
	damage_bar.add_theme_stylebox_override("fill", damage_fill)
	damage_bar.add_theme_stylebox_override("background", bg.duplicate())
	
	_sync_bar_from_parent()

func _process(delta):
	_sync_bar_from_parent()
	
	# Smooth delayed damage bar animation
	if damage_bar and bar:
		if bar.value < damage_bar.value:
			damage_bar_target = bar.value
		
		if damage_bar.value > damage_bar_target:
			var lerp_speed = 2.0 / damage_delay
			damage_bar.value = lerp(damage_bar.value, damage_bar_target, lerp_speed * delta)
			if abs(damage_bar.value - damage_bar_target) < 0.5:
				damage_bar.value = damage_bar_target
		else:
			damage_bar.value = bar.value
	
	# Toggle visibility/LookAt
	var watcher = get_viewport().get_camera_3d()
	if watcher:
		var dist = global_transform.origin.distance_to(watcher.global_transform.origin)
		visible = dist <= show_distance
		look_at(watcher.global_transform.origin, Vector3.UP)

func _sync_bar_from_parent():
	var parent = get_parent()
	if not parent: return
	
	# Duck-typing: Check if parent has 'health' and 'max_health'
	if "health" in parent and "max_health" in parent:
		var max_hp = max(1.0, float(parent.max_health))
		var current_hp = float(parent.health)
		
		bar.max_value = max_hp
		bar.value = current_hp
		
		if damage_bar:
			damage_bar.max_value = max_hp
			if damage_bar.value == 0 and current_hp > 0: # Init
				damage_bar.value = current_hp
				damage_bar_target = current_hp
				
		if value_label:
			value_label.text = "%d / %d" % [int(current_hp), int(max_hp)]
	else:
		# Fallback for editor or misconfigured parent
		if Engine.is_editor_hint():
			bar.value = 100
