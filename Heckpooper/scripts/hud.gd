extends CanvasLayer

enum game_states { PAUSED, PLAY_GAME}
@export var current_game_state : game_states = game_states.PLAY_GAME
@onready var pause_screen = $"Pause Screen"

func _ready():
	pause_screen.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	pause_toggle(event)

func pause_toggle(event):
	
	#If ESCAPE key is pressed
	if(event.is_action_pressed("ui_cancel")):
		
		#If Pause into Playing Game -> Mouse Hide, Resume Time
		if(current_game_state == game_states.PAUSED):
			current_game_state = game_states.PLAY_GAME
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			pause_screen.visible = false
			
		# If Playing Game into Pause -> Mouse is Visible, Stop time
		elif (current_game_state == game_states.PLAY_GAME):
			current_game_state = game_states.PAUSED
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			pause_screen.visible = true

func _on_coin_collected(coins):
	
	$Coins.text = str(coins)
