extends Node2D


# Types
# 0 line
# 1 square
# 2 L
# 3 Reverse L
# 4 T
# 5 Z
# 5 S

const TYPE_COLORS = [
	Color("#73bed3"),
	Color("#ecc166"),
	Color("#e1875c"),
	Color("#585aca"),
	Color("#be65bf"),
	Color("#cd5454"),
	Color("#a8ca85")
	]

@onready var blocks : Array[Sprite2D] = [ 
	get_node("%block"),
	get_node("%block2"),
	get_node("%block3"),
	get_node("%block4"),
]

func _ready() -> void:
	pass

func _load_block(type: int) -> void:
	for block in blocks:
		block.modulate = TYPE_COLORS[type]

func _process(delta: float) -> void:
	if OS.is_debug_build():
		if Input.is_key_pressed(KEY_1):
			_load_block(1)
		if Input.is_key_pressed(KEY_2):
			_load_block(2)
		if Input.is_key_pressed(KEY_3):
			_load_block(3)
		if Input.is_key_pressed(KEY_4):
			_load_block(4)
		if Input.is_key_pressed(KEY_5):
			_load_block(5)
		if Input.is_key_pressed(KEY_6):
			_load_block(6)
		if Input.is_key_pressed(KEY_7):
			_load_block(0)

