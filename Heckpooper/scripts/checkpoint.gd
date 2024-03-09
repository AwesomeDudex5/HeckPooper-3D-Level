extends Node3D

@onready var audio_player = $AudioStreamPlayer3D
var checkpoint_reached : bool = false



func _on_area_3d_area_entered(area):
	print("Checkpoint reached")
	if(area.is_in_group("Player")):
		if(checkpoint_reached == false):
			checkpoint_reached = true
			audio_player.play()
