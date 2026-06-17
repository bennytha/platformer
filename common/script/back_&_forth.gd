extends PathFollow2D

var direction = 1
@export var speed: float = .010

func _process(_delta: float) -> void:
	progress_ratio += speed * direction 
	
	if progress_ratio == 1:
		direction = -1
	if progress_ratio ==0:
		direction = 1
