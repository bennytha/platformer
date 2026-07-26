extends GPUParticles2D

func release_confetti():
	restart()
	# Automatically destroy after all particles expire
	await get_tree().create_timer(lifetime).timeout
	queue_free()
