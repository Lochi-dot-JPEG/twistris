extends GPUParticles2D

func _ready() -> void:
	emitting = true

func _finished():
	queue_free()


