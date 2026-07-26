extends Node2D

var local_bus: GameContainer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

const WIN = preload("uid://dtltiwysu7yd3")

var is_activated: bool = false

func _ready() -> void:
	local_bus = UtilsFuncs.find_local_bus(self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	# 1. Guard clause: Return if already activated
	if is_activated:
		return
		
	if body.is_in_group('player'):
		# Lock state immediately so fast multi-collisions are ignored
		is_activated = true 
		
		# Disable the Area2D collision so it cannot trigger again
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		
		animated_sprite_2d.play('moving')
		AudioManager.play_sfx(WIN)
		
		# 2. Check if the particle node is still valid in memory
		if is_instance_valid(gpu_particles_2d):
			gpu_particles_2d.release_confetti()
		
		await get_tree().create_timer(0.5).timeout
		if local_bus:
			local_bus.player_reached_end.emit()
