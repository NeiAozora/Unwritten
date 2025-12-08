extends PlayerVisuals
class_name BeeVisuals

# Reference to the bee mesh's AnimationPlayer
var anim_player: AnimationPlayer

# Override to prevent crash on missing nodes (HUD, Skeleton, etc.)
func _ready():
	# Find AnimationPlayer in the Visuals child (bee.glb)
	var visuals = get_node_or_null("Visuals")
	if visuals:
		anim_player = visuals.get_node_or_null("AnimationPlayer")
	
	# Start idle animation
	if anim_player:
		play_animation("idlewalk")

# Override to simply store the model, avoiding humanoid-specific setup
func accept_model(_model : PlayerModel):
	model = _model
	# No HUD, no skeleton retargeting needed for now.

# Override to update animation based on model state
func _process(_delta):
	if not model or not anim_player:
		return
	
	# Check current move and play appropriate animation
	if model.current_move:
		var move_name = model.current_move.move_name
		match move_name:
			"idle":
				play_animation("idlewalk")
			"walk", "run", "sprint":
				play_animation("idlewalk")
			"attack", "light_attack":
				play_animation("attack_001")
			_:
				play_animation("idlewalk")

func play_animation(anim_name: String):
	if anim_player and anim_player.has_animation(anim_name):
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name)

func flash_damage():
	# TODO: Implement simple mesh flash for bee if needed
	pass

func flash_attack():
	pass
