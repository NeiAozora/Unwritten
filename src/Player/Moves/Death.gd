extends Move


func check_relevance(input : InputPackage) -> String:
	# If permanent death is enabled for enemy, lock them in death state
	if model.permanent_death_enabled and model.is_enemy:
		return "okay"  # Stay in death state, never transition out
	
	# Normal behavior - allow transitions
	return super.check_relevance(input)


func on_exit_state():
	# Check if permanent death is enabled
	# If enabled, enemy stays dead and won't respawn
	if model.permanent_death_enabled and model.is_enemy:
		# Keep enemy dead - don't restore health
		print("Enemy permanently dead - no respawn")
		return
	
	# Normal respawn behavior (for player or if permanent death disabled)
	resources.gain_health(987651468)


func on_enter_state():
	# Stop all movement immediately on death.
	player.velocity = Vector3.ZERO
	player.floor_snap_length = 0.0


func update(_input : InputPackage, _delta : float):
	# Keep the body frozen while dead.
	player.velocity = Vector3.ZERO
