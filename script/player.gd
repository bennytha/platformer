extends CharacterBody2D

@onready var input_component: InputComponent = $InputComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Inject dependencies into the state machine
	state_machine.init(self, velocity_component, input_component)

# External method to trigger the hit state from an enemy or hazard
func take_damage(knockback_dir: float) -> void:
	velocity_component.velocity.x = knockback_dir * 300
	state_machine.on_child_transitioned("hit")
