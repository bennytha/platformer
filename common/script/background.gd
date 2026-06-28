extends Parallax2D

@export var speed = 10
@export var texture: CompressedTexture2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.texture = texture

func _process(delta: float) -> void:
	sprite_2d.region_rect.position += delta * Vector2(speed,speed)
