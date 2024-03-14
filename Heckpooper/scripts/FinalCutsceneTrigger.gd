extends Area3D

@onready var cutscene_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_area_entered(area):
	#print(area.get_parent().get_name())
	if(area.is_in_group("Player")):
		#print("Cutscene trigger")
		cutscene_player.play("Final_Cutscene")
		await get_tree().create_timer(10.0).timeout
		get_tree().quit()
