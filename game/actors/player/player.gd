extends CharacterBody2D

@export var level_tilemap: TileMapLayer
@onready var input_component: InputComponent = $InputComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent

signal player_respawn_ready

func _ready() -> void:
	state_machine.init(self, velocity_component, input_component,animated_sprite_2d)
	health_component.died.connect(_on_player_death)

func _on_hurt_box_area_entered(hitbox: Area2D) -> void:
	if state_machine.current_state is DeathState:
		return
	
	var knockback_direction: float = 1.0
	if hitbox.global_position.x > global_position.x:
		knockback_direction = -1.0 
		
	var damage_to_take: int = 1
	if "damage_amount" in hitbox:
		damage_to_take = hitbox.damage_amount
	health_component.damage(damage_to_take)
	
	if health_component.current_health > 0:
		take_damage(knockback_direction)

func take_damage(knockback_dir: float) -> void:
	velocity_component.velocity.x = knockback_dir * 250.0
	velocity_component.velocity.y = -200.0 
	
	state_machine.on_child_transitioned("hit")
	

func _on_interact_area_entered(interaction_area: Area2D) -> void:
	if 'bounce_velocity' in interaction_area:
		var force_jump_state = state_machine.states.get('force_jump')
		if force_jump_state:
			force_jump_state.custom_bounce_force = interaction_area.bounce_velocity
			state_machine.on_child_transitioned('force_jump')

func _on_player_death() -> void:
	print("Player has run out of health!")
	state_machine.on_child_transitioned('death')
