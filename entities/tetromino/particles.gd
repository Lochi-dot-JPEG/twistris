extends GPUParticles2D

func _ready() -> void:
	emitting = true
	finished.connect(queue_free)

func _finished():
	queue_free()


