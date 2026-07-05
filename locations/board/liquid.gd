extends Area2D

const RISE_SPEED = 5
var height = 0


func _process(delta: float) -> void:
	height += delta * RISE_SPEED
	position.y = 360 - height
