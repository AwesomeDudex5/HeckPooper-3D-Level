extends Node3D

@export_group("Properties")
@export var target: Node
@export var auto_set_behind_player : bool = true

#Camera Type Enum
enum camera_types{ Joystick, Mouse}
@export var camera_mode : camera_types = camera_types.Joystick
@export var invert_x : bool = false
@export var invert_y : bool = false

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10
@export var starting_zoom = 10

@export_group("Rotation")
@export var rotation_speed = 120

@export_group("Mouse Stats")
@export var mouse_sensitivity := 0.001
@export var low_view_bound := 5
var twist_input := 0.0 #Horizontal Mouse
var pitch_input := 0.0 #Vertical Mouse

var camera_rotation:Vector3
var zoom

@onready var camera = $PitchPivot/Camera
@onready var pitch_pivot = $PitchPivot
#@onready var cam_origin_point = $PitchPivot/OriginPoint
#@onready var cam_raycast = $PitchPivot/Camera/RayCast3D

func _ready():
	
	pitch_pivot.add_excluded_object(target)
	camera_rotation = rotation_degrees
	#camera_rotation = target.rotation
	zoom = starting_zoom
	#pitch_pivot.target_position = Vector3(0,0,zoom) # set if raycast pitchpivot
	pitch_pivot.spring_length = zoom #set if springarm pitch pivot
	
	#set camera view behind player	
	if(auto_set_behind_player == true):
		self.position.x = target.position.x
		self.position.z = target.position.z
		self.rotation.y = target.rotation.y
		self.rotate_y(PI)
	
	# Make mouse invisible and confined in window if camera type mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	
	#-----SPRING ARM 3D PITCH PIVOT
	#pitch_pivot.spring_length = zoom
	
	##Zoom Camera in by adjusting the spring length
	#pitch_pivot.spring_length = lerp(pitch_pivot.spring_length, float(zoom), 4 * delta)
	#pitch_pivot.spring_length = clamp(pitch_pivot.spring_length, zoom_maximum, zoom_minimum )
	##print("Hit Length: " + str(pitch_pivot.get_hit_length()))
	#
	#var spring_get_hit_length = pitch_pivot.get_hit_length()
	#spring_get_hit_length = clamp(spring_get_hit_length, zoom_maximum, zoom_minimum)
	#camera.position = lerp(camera.position, Vector3(camera.position.x,camera.position.y,spring_get_hit_length), 4 * delta)
	#print("pitch pivor rotation: " + str(pitch_pivot.rotation))
	
	#Zoom Camera in by adjusting the spring length
	pitch_pivot.spring_length = lerp(pitch_pivot.spring_length, float(zoom), 4 * delta)
	pitch_pivot.spring_length = clamp(pitch_pivot.spring_length, zoom_maximum, zoom_minimum )
	#print("Hit Length: " + str(pitch_pivot.get_hit_length()))
	
	#set camera zoom upon hitting a wall
	var spring_get_hit_length = pitch_pivot.get_hit_length()
	spring_get_hit_length = clamp(spring_get_hit_length, zoom_maximum, zoom_minimum)
	
	camera.position = camera.position.lerp(Vector3(0, 0, pitch_pivot.spring_length), 8 * delta)
	
	if(camera_mode == camera_types.Joystick):
		# Set position and rotation to targets
		self.position = self.position.lerp(target.position, delta * 4)
		rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
		#camera.position = camera.position.lerp(Vector3(0, 0, pitch_pivot.spring_length), 8 * delta)
	
		# Handle Joystick input
		handle_input(delta)
	
	if(camera_mode == camera_types.Mouse):		
		# Set position and rotation to targets
		self.position = self.position.lerp(target.position, delta * 4)

		#camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
		

#Joystick Input
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
	#print("Camera Joy Rot: " + str(camera_rotation))
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)

#Mouse Input
func _unhandled_input(event):
	if(camera_mode == camera_types.Mouse):
		
		#Mouse Move Input
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
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-59), deg_to_rad(low_view_bound))
			#print("Pivot X rotation: " + str((pitch_pivot.rotation)))
		
		#Zoom
		if(event is InputEventMouseButton):
			zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * 0.167
			zoom = clamp(zoom, zoom_maximum, zoom_minimum)
		twist_input = 0
		pitch_input = 0

