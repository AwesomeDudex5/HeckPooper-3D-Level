extends Node3D

@onready var player_node = $"../../Player"
@onready var checkpoint = preload("res://objects/checkpoint.tscn")
@onready var checkpoint_text = $"Can Place Text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if player_node != null:
		### Text Look at the player's position (excluding Y-axis for flat rotation)
		#checkpoint_text.look_at(player_node.transform.origin, Vector3(0, 1, 0))

func _on_area_3d_area_entered(area):
	if(area.is_in_group("Player")):
		print("Can Place a Checkpoint")
		 # Instantiate the checkpoint object
		var checkpoint_instance = checkpoint.instantiate()  # Create an instance of the checkpoint scene
		
		# Set position (adjust coordinates as needed)
		checkpoint_instance.transform.origin = Vector3(0, -0.5, 0)

		# Add the instantiated checkpoint to the scene tree
		add_child(checkpoint_instance)
		
		#disable text and area
		checkpoint_text.visible = false
		$"Detection Sphere".queue_free()
		
