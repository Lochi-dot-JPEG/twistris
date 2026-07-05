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

const BLOCK_POSITIONS = [
	# Line
	[
		[ # Unrotated
			[0,0], [-1,0], [1,0], [2,0] ],
		[ # 90degrees
			[1,0], [1,1], [1,-1], [1,2] ],
		[ # 180degrees
			[0,1], [-1,1], [1,1], [2,1] ],
		[ # 270degrees
			[0,0], [0,1], [0,-1], [0,2] ],
	],

	[ # Square
		[ # Unrotated
			[0,0], [1,0], [1,1], [0,1] ],
		[ # 90degrees
			[0,0], [1,0], [1,1], [0,1] ],
		[ # 180degrees
			[0,0], [1,0], [1,1], [0,1] ],
		[ # 270degrees
			[0,0], [1,0], [1,1], [0,1] ],
	],
	[ # L
		[ # Unrotated
			[0,0], [1,0], [-1,0], [1,-1] ],
		[ # 90degrees
			[0,0], [0,1], [1,1], [0,-1] ],
		[ # 180degrees
			[0,0], [1,0], [-1,0], [-1,1] ],
		[ # 270degrees
			[0,0], [0,1], [-1,-1], [0,-1] ],
	],
	[ # Reverse L
		[ # Unrotated
			[0,0], [1,0], [-1,0], [-1,-1] ],
		[ # 90degrees
			[0,0], [0,1], [1,-1], [0,-1] ],
		[ # 180degrees
			[0,0], [1,0], [-1,0], [1,1] ],
		[ # 270degrees
			[0,0], [0,1], [0,-1], [-1,1] ],
	],
	[ # T
		[ # Unrotated
			[0,0], [1,0], [-1,0], [0,-1] ],
		[ # 90degrees
			[0,0], [1,0],  [0,-1], [0,1] ],
		[ # 180degrees
			[0,0], [1,0], [-1,0],  [0,1] ],
		[ # 270degrees
			[0,0], [-1,0], [0,-1], [0,1] ],
	],
	[ # Z
		[ # Unrotated
			[0,0], [1,0], [0,-1], [-1,-1] ],
		[ # 90degrees
			[0,0], [1,0],  [0,1], [1,-1] ],
		[ # 180degrees
			[0,1], [1,1], [0,0], [-1,0] ],
		[ # 270degrees
			[0,0], [-1,0], [0,-1], [-1,1] ],
	],
	[ # S
		[ # Unrotated
			[0,0], [-1,0], [0,-1], [1,-1] ],
		[ # 90degrees
			[0,0], [1,0],  [1,-1], [0,1] ],
		[ # 180degrees
			[0,0], [-1,1], [1,0],  [0,1] ],
		[ # 270degrees
			[-1,0], [0,0],  [0,1], [-1,-1] ],
	],
]
const DROP_TIME = 1
const TIME_DROP_INCREASE = 0.002 # Time removed from drop time each second
const MAX_TIME_AFFECT = 180000 # Max milliseconds to continue increasing drop speed

@onready var blocks : Array[CharacterBody2D] = [ 
	get_node("%block"),
	get_node("%block2"),
	get_node("%block3"),
	get_node("%block4"),
]

var active = true
var piece_rotation := 0
var type := 0
var since_last_drop := 0.0
var start_time = 0

signal grounded

func _ready() -> void:
	for block in blocks:
		for b in blocks:
			if b != block:
				block.add_collision_exception_with(b)


func _load_block(_type: int) -> void:
	type = _type
	for block in blocks:
		block.modulate = TYPE_COLORS[type]
	piece_rotation = 0
	_load_rotation()


func _load_rotation() -> void:
	for i in 4:
		var pos = BLOCK_POSITIONS[type][piece_rotation][i]
		blocks[i].position.x = pos[0] * 32
		blocks[i].position.y = pos[1] * 32

func _can_move_direction(dir: Vector2) -> bool:
	for i in blocks:
		var col : KinematicCollision2D= i.move_and_collide(dir * 32, true)
		if col != null && col.get_collider() != null:
			return false
	return true


func _process(delta: float) -> void:
	since_last_drop += delta * 5
	var drop_time = clampf(Time.get_ticks_msec() - start_time,0,MAX_TIME_AFFECT) / 1000.0
	var speed = clamp((DROP_TIME - drop_time * TIME_DROP_INCREASE), 0.1, DROP_TIME)
	print(speed)
	while since_last_drop > speed:
		print("loops")
		
		var can_move = _can_move_direction(Vector2(0,1))

		if can_move:
			position.y += 32
		else:
			grounded.emit()
		since_last_drop -= speed

	if active:
		if Input.is_action_pressed("right"):
			if _can_move_direction(Vector2(1,0)):
				position.x += 32
		if Input.is_action_pressed("left"):
			if _can_move_direction(Vector2(-1,0)):
				position.x -= 32
		if Input.is_action_just_pressed("rotate"):
			piece_rotation += 1 
			while piece_rotation < 0:
				piece_rotation += 4
			while piece_rotation > 3:
				piece_rotation -= 4
			_load_rotation()

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

