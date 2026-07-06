extends GPUParticles2D

@export var also_activate : Array[GPUParticles2D]
func _ready() -> void:
	emitting = true
	for i in also_activate:
		i.emitting = true

func _finished():
	queue_free()


