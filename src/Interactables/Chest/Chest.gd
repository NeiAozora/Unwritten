extends Node3D

@onready var animation_player : AnimationPlayer
@onready var area_3d : Area3D = $Area3D

@export var open_animation_name : String = ""

var is_open : bool = false

func _ready():
	# Try to find the animation player in the children (it wraps the imported model)
	animation_player = _find_animation_player(self)
	
	if animation_player:
		print("Chest: Found AnimationPlayer. Animations: ", animation_player.get_animation_list())
		if open_animation_name == "":
			# Try to deduce open animation
			for anim in animation_player.get_animation_list():
				if "open" in anim.to_lower():
					open_animation_name = anim
					break
	else:
		print("Chest: AnimationPlayer NOT found!")

	if area_3d:
		area_3d.body_entered.connect(_on_body_entered)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var res = _find_animation_player(child)
		if res: return res
	return null

func _on_body_entered(body: Node3D):
	if is_open: return
	if body.is_in_group("player") or body.name == "Player":
		open_chest()

func open_chest():
	if not animation_player: return
	
	var anim_to_play = ""
	
	if open_animation_name != "" and animation_player.has_animation(open_animation_name):
		anim_to_play = open_animation_name
	else:
		var anims = animation_player.get_animation_list()
		if anims.size() > 0:
			anim_to_play = anims[0]
	
	if anim_to_play != "":
		# Set looping
		var anim_res = animation_player.get_animation(anim_to_play)
		if anim_res:
			anim_res.loop_mode = Animation.LOOP_LINEAR
		
		animation_player.play(anim_to_play)
		is_open = true
		print("Chest: Opening with looping animation: ", anim_to_play)
