extends Control


@onready var board = %Board
@onready var label : Label = %Label
@onready var title : Control = $TitleScreen
@onready var play : Control = %Play
@onready var settings : Control = %Settings
@onready var help : Control = %Help
@onready var game_over : Control = %GameOver
@onready var lose_label : Control = %LoseLabel
@onready var continue_button : Button = %Continue
@onready var help_panel : Control = %HelpPanel
@onready var help_continue_button : Button = %HelpContinue

func _ready() -> void:
	board.update_ui.connect(_update_ui)
	board.failed.connect(_game_over)
	help.pressed.connect(_help)
	settings.pressed.connect(_settings)
	play.pressed.connect(_play)
	continue_button.pressed.connect(_back_to_title)
	help_continue_button.pressed.connect(_back_to_title)
	_back_to_title()

func _back_to_title():
	board._stop_game()
	label.hide()
	title.show()
	game_over.hide()
	help_panel.hide()


func _game_over() -> void:
	board._stop_game()
	game_over.show()
	lose_label.text = "Your final score is:\n" + str(board.score)


func _play() -> void:
	label.show()
	board._start_game()
	title.hide()


func _settings() -> void:
	pass


func _help() -> void:
	help_panel.show()


func _update_ui() -> void:
	label.text = "Score:\n" + str(board.score)
