extends Node3D
class_name PlayerVisuals

@onready var model : PlayerModel

@onready var beta_joints = get_node_or_null("Beta_Joints")
@onready var beta_surface = get_node_or_null("Beta_Surface")

@onready var sword_visuals_1 = get_node_or_null("SwordVisuals1")
@onready var stamina_label = get_node_or_null("Stamina _bar_")
@onready var health_label = get_node_or_null("Health _bar_")
@onready var health_bar = get_node_or_null("UI/Status/VBox/HealthBar")
@onready var stamina_bar = get_node_or_null("UI/Status/VBox/StaminaBar")
@onready var health_value_label = get_node_or_null("UI/Status/VBox/HealthBar/Value")
@onready var stamina_value_label = get_node_or_null("UI/Status/VBox/StaminaBar/Value")

var default_surface_modulate : Color
var default_sword_modulate : Color

var surface_material : StandardMaterial3D
var sword_material : StandardMaterial3D
var health_style := StyleBoxFlat.new()
var stamina_style := StyleBoxFlat.new()
var sword_visible_timer: float = 0.0  # Timer to keep sword visible
const SWORD_LINGER_TIME: float = 0.8  # Seconds sword stays visible after attack ends

func accept_model(_model : PlayerModel):
	model = _model
	if beta_surface: beta_surface.skeleton = _model.skeleton.get_path()
	if beta_joints: beta_joints.skeleton = _model.skeleton.get_path()
	surface_material = _extract_material(beta_surface)
	sword_material = _extract_material(sword_visuals_1)
	if surface_material:
		default_surface_modulate = surface_material.albedo_color
	if sword_material:
		default_sword_modulate = sword_material.albedo_color
	if has_node("UI"): $UI.visible = not model.is_enemy
	if health_bar: health_bar.max_value = model.resources.max_health
	if stamina_bar: stamina_bar.max_value = model.resources.max_stamina
	if health_bar: health_bar.value = model.resources.health
	if stamina_bar: stamina_bar.value = model.resources.stamina
	_setup_status_bar_styles()


func _process(delta):
	update_resources_interface()
	adjust_weapon_visuals(delta)


func adjust_weapon_visuals(delta: float):
	if sword_visuals_1: sword_visuals_1.global_transform = model.active_weapon.global_transform
	
	# Reset timer when attacking starts
	if model.active_weapon.is_attacking:
		sword_visible_timer = SWORD_LINGER_TIME
	
	# Decrease timer
	if sword_visible_timer > 0:
		sword_visible_timer -= delta
	
	# Show sword if timer is active
	if sword_visuals_1: sword_visuals_1.visible = sword_visible_timer > 0


func update_resources_interface():
	if not model.is_enemy:
		if stamina_label: stamina_label.text = "Stamina " + "%10.3f" % model.resources.stamina
		if health_label: health_label.text = "Health " + "%10.3f" % model.resources.health
		if health_bar: health_bar.value = model.resources.health
		if stamina_bar: stamina_bar.value = model.resources.stamina
		if health_value_label: health_value_label.text = "%d / %d" % [round(model.resources.health), round(model.resources.max_health)]
		if stamina_value_label: stamina_value_label.text = "%d / %d" % [round(model.resources.stamina), round(model.resources.max_stamina)]


func flash_damage():
	# Briefly flash the character to show impact.
	if not is_inside_tree():
		return
	if not surface_material:
		return
	var tween = create_tween()
	tween.tween_property(surface_material, "albedo_color", Color(1, 0.4, 0.4, 1), 0.05)
	tween.tween_property(surface_material, "albedo_color", default_surface_modulate, 0.12)


func flash_attack():
	# Highlight weapon on attack start.
	if not is_inside_tree():
		return
	if not sword_material:
		return
	var tween = create_tween()
	tween.tween_property(sword_material, "albedo_color", Color(1, 1, 0.3, 1), 0.05)
	tween.tween_property(sword_material, "albedo_color", default_sword_modulate, 0.12)


func _extract_material(node : Node) -> StandardMaterial3D:
	if not node:
		return null
	var mesh_instance : MeshInstance3D = null
	if node is MeshInstance3D:
		mesh_instance = node
	else:
		for child in node.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	if mesh_instance == null:
		return null
	var mat : Material = mesh_instance.get_active_material(0)
	if mat:
		mat = mat.duplicate()
		mesh_instance.material_override = mat
	if mat is StandardMaterial3D:
		return mat
	return null


func _setup_status_bar_styles():
	# Health: green fill, dark background
	health_style.bg_color = Color(0.12, 0.35, 0.12, 1)
	health_style.border_width_left = 1
	health_style.border_width_top = 1
	health_style.border_width_right = 1
	health_style.border_width_bottom = 1
	health_style.border_color = Color(0.05, 0.15, 0.05, 1)
	if health_bar:
		health_bar.add_theme_stylebox_override("fill", health_style)
		var health_bg := health_style.duplicate()
		health_bg.bg_color = Color(0.05, 0.08, 0.05, 0.8)
		health_bar.add_theme_stylebox_override("background", health_bg)

	# Stamina: orange fill
	stamina_style.bg_color = Color(0.9, 0.5, 0.1, 1)
	stamina_style.border_width_left = 1
	stamina_style.border_width_top = 1
	stamina_style.border_width_right = 1
	stamina_style.border_width_bottom = 1
	stamina_style.border_color = Color(0.25, 0.15, 0.05, 1)
	if stamina_bar:
		stamina_bar.add_theme_stylebox_override("fill", stamina_style)
		var stamina_bg := stamina_style.duplicate()
		stamina_bg.bg_color = Color(0.1, 0.06, 0.02, 0.8)
		stamina_bar.add_theme_stylebox_override("background", stamina_bg)
