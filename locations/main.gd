extends Control


@onready var board = %Board
@onready var label : Label = %Label

func _ready() -> void:
	board.update_ui.connect(_update_ui)

func _update_ui() -> void:
	label.text = "Lives\n" + str(board.lives)
	

