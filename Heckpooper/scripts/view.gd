extends Node3D

@export_group("Properties")
@export var target: Node

#Camera Type Enum
enum camera_types{ Joystick, Mouse}
@export var camera_mode : camera_types = camera_types.Joystick
@export var invert_x : bool = false
@export var invert_y : bool = false

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120

@export_group("Mouse Stats")
@export var mouse_sensitivity := 0.001
@export var low_view_bound := 5
var twist_input := 0.0 #Horizontal Mouse
var pitch_input := 0.0 #Vertical Mouse

var camera_rotation:Vector3
var zoom = 10

@onready var camera = $PitchPivot/Camera
@onready var pitch_pivot = $PitchPivot

func _ready():
	
	camera_rotation = rotation_degrees # Initial rotation
	
	# Make mouse invisible and confined in window if camera type mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#Set View Pivot and Camera Position instantly in mouse mode
	if(camera_mode == camera_types.Mouse):
		self.position = target.position
		rotation_degrees = camera_rotation
		camera.position = Vector3(0,0, zoom)


func _physics_process(delta):
	
	if(camera_mode == camera_types.Joystick):
		# Set position and rotation to targets
		self.position = self.position.lerp(target.position, delta * 4)
		rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
		camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
	
		# Handle Joystick input
		handle_input(delta)
	
	if(camera_mode == camera_types.Mouse):		
		# Set position and rotation to targets
		self.position = self.position.lerp(target.position, delta * 4)
		
		camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
		


func handle_input(delta):	
	# Rotation
	var input := Vector3.ZERO
	
	input.y = Input.get_axis("camera_left", "camera_right")
	input.x = Input.get_axis("camera_up", "camera_down")
	
	if(invert_x == true):
		input.x = input.x * -1
	if(invert_y == true):
		input.y = input.y * -1
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -80, 10)
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)

func _unhandled_input(event):
	if(camera_mode == camera_types.Mouse):
		if(event is InputEventMouseMotion):
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
			
			if(invert_x == true):
				twist_input = twist_input * -1
			if(invert_y == true):
				pitch_input = pitch_input * -1
			
			#Rotation
			self.rotate_y(deg_to_rad(twist_input))
			pitch_pivot.rotate_x(deg_to_rad(pitch_input))
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(low_view_bound))
		if(event is InputEventMouseButton):
			zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * 0.167
			zoom = clamp(zoom, zoom_maximum, zoom_minimum)
		twist_input = 0
		pitch_input = 0

