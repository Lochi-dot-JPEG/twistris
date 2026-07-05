extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var crush_area : Area2D= %CrushArea
@onready var sprite : AnimatedSprite2D= $AnimatedSprite2D

var _active = false
var active:
	get:
		return _active
	set(value):
		_active = value
		if value:
			modulate = Color.WHITE
		else:
			modulate = Color.GRAY

signal crushed

func _ready() -> void:
	crush_area.body_entered.connect(_crush)
	crush_area.area_entered.connect(_crush)

func _crush(body) -> void:
	if body != self:


		sprite.play("death")
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(2).timeout
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT
		crushed.emit()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if active: 
		sprite.play("default")
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("left", "right")
		if direction:
			sprite.flip_h = direction > 0
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		sprite.play("inactive")

	move_and_slide()

