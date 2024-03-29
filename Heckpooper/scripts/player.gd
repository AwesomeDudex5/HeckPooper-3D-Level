extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var sprint_speed = 800
@export var jump_strength = 7

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true
var can_sprint = true

var coins = 0

var current_spawn_point

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer

# Functions

func _ready():
	#rotation_direction = get_rotation_degrees().y
	#rotation.y = rotation_direction
	current_spawn_point = self.position
	print(current_spawn_point)

func _physics_process(delta):	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects()
	
	# Movement

	var applied_velocity: Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	var desired_direction = Vector3.ZERO
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# Falling/respawning
	
	if position.y < -10:
		death()
	
	# Animation for scale (jumping and landing)
	
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	# Animation when landing
	
	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects():
	
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animation.play("walk", 0.5)
			particles_trail.emitting = true
			sound_footsteps.stream_paused = false
		else:
			animation.play("idle", 0.5)
	else:
		animation.play("jump", 0.5)

# Handle movement input

func handle_controls(delta):
	
	var speed_to_move = movement_speed
	
	#sprint check
	#only sprint when on floor
	if(is_on_floor()):
		can_sprint = true
	else:
		can_sprint = false
	
	if(can_sprint == true):
		if(Input.is_action_pressed("Sprint")):
			speed_to_move = sprint_speed
			jump_single = false
			jump_double = false
		else :
			speed_to_move = movement_speed
			jump_single = true
			jump_double = true
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	
	movement_velocity = input * speed_to_move * delta
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("res://sounds/jump.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			
			jump_double = false
			model.scale = Vector3(0.5, 1.5, 0.5)
			
		if(jump_single): jump()

# Handle gravity

func handle_gravity(delta):
	
	gravity += 25 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func jump():
	
	gravity = -jump_strength
	
	model.scale = Vector3(0.5, 1.5, 0.5)
	
	jump_single = false;
	jump_double = true;

# Collecting coins

func collect_coin():
	
	coins += 1
	
	coin_collected.emit(coins)

func death():
	#get_tree().reload_current_scene()
	#translate(current_spawn_point)\
	#print("Deading")
	self.position = current_spawn_point

func _on_area_3d_body_entered(body):
	#print(body.name)
	if(body.is_in_group("Trap")):
		death()

func _on_area_3d_area_entered(area):
	#print(area.name)
	if(area.is_in_group("Checkpoint")):
		current_spawn_point = area.get_parent().global_position
