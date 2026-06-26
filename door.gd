extends Area2D

@export var keys_required: int = 2
@export var key_item_name: String = "Key"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var interaction_collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var prompt_label: Label = $Label

var is_door_open:= false
func _ready() -> void:
	prompt_label.visible = false

# Called automatically by the player's InteractionDetector when approaching
func show_prompt(player: CharacterBody2D) -> void:
	if not is_door_open:
		prompt_label.visible = true
		_update_prompt_text(player)

# Called automatically when the player walks away
func hide_prompt() -> void:
	prompt_label.visible = false

# Handles updating the visual text layout based on player's current inventory status
func _update_prompt_text(player: CharacterBody2D) -> void:
	if not player.has_node("InventoryComponent"):
		return
		
	var inventory = player.get_node("InventoryComponent") as InventoryComponent
	var keys_carried = _count_keys_in_inventory(inventory)
	
	if keys_carried >= keys_required:
		prompt_label.text = "[E] Interact to Unlock"
	else:
		prompt_label.text = "Locked: Need %s keys (%d/%d)" % [key_item_name, keys_carried, keys_required]

# The core interaction execution code triggered when pressing 'E'
func interact(player: CharacterBody2D) -> void:
	if not player.has_node("InventoryComponent"):
		return
		
	var inventory = player.get_node("InventoryComponent") as InventoryComponent
	var keys_carried = _count_keys_in_inventory(inventory)
	
	if keys_carried >= keys_required:
		_consume_keys(inventory)
		_open_door()
	else:
		print("Cannot open yet. Missing keys!")
		_update_prompt_text(player)

# Helper function to see how many matching keys the player holds
func _count_keys_in_inventory(inventory: InventoryComponent) -> int:
	var count = 0
	for item in inventory.items:
		if item.item_name.to_lower() == key_item_name.to_lower():
			count += 1
	return count

# Helper function to delete the used keys from inventory upon unlock success
func _consume_keys(inventory: InventoryComponent) -> void:
	var consumed = 0
	# Loop backwards when removing items from an array to prevent skip indexing
	for i in range(inventory.items.size() - 1, -1, -1):
		if consumed >= keys_required:
			break
		if inventory.items[i].item_name.to_lower() == key_item_name.to_lower():
			inventory.remove_item(inventory.items[i])
			consumed += 1

func _open_door() -> void:
	print("Door completely opened!")
	# Play opening animation here or drop structural collisions
	#queue_free()
	is_door_open = true
	hide_prompt()
	collision_shape_2d.disabled = true
	interaction_collision_shape_2d.disabled = true
	animated_sprite_2d.play('open')
