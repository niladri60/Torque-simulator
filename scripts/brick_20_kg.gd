extends RigidBody2D

# This makes "Weight" appear in the inspector of every brick instance
@export var weight : float = 20.0

var being_dragged : bool = false
var drag_offset : Vector2

# Camera reference - assign in inspector or it will auto-detect
@export var camera : Camera2D

func _ready():
	mass = weight
	gravity_scale = 1.0
	$Label.text = str(weight) + "kg"   # Make sure your Label node is named "Label"
	
	# Auto-detect camera if not assigned
	if camera == null:
		camera = get_viewport().get_camera_2d()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Clicked down — check if mouse is over this brick
			if _is_mouse_inside():
				being_dragged = true
				drag_offset = global_position - get_global_mouse_position()
				freeze = true                     # Stop physics while dragging
				z_index = 10                      # Bring to front so it's on top
		else:
			# Released mouse button anywhere
			if being_dragged:
				being_dragged = false
				freeze = false                    # Let physics work again
				z_index = 0                       # Back to normal layer

	# While holding the mouse button, move the brick
	if event is InputEventMouseMotion and being_dragged:
		var new_position = get_global_mouse_position() + drag_offset
		global_position = _clamp_position_to_bounds(new_position)

# Helper: is the mouse cursor inside the brick?
func _is_mouse_inside() -> bool:
	var shape = $CollisionShape2D.shape
	var local_mouse = to_local(get_global_mouse_position())
	if shape is RectangleShape2D:
		var extents = shape.extents
		return abs(local_mouse.x) < extents.x and abs(local_mouse.y) < extents.y
	elif shape is CircleShape2D:
		return local_mouse.length() < shape.radius
	return false

# Clamp position to stay within screen/camera bounds
func _clamp_position_to_bounds(position: Vector2) -> Vector2:
	var viewport_rect = get_viewport_rect()
	var collision_shape = $CollisionShape2D
	var shape_extents = Vector2.ZERO
	
	# Get the collision shape extents
	if collision_shape and collision_shape.shape:
		if collision_shape.shape is RectangleShape2D:
			shape_extents = collision_shape.shape.extents
		elif collision_shape.shape is CircleShape2D:
			shape_extents = Vector2(collision_shape.shape.radius, collision_shape.shape.radius)
	
	var min_bound = Vector2.ZERO
	var max_bound = Vector2.ZERO
	
	if camera:
		# Use camera bounds
		var camera_center = camera.global_position
		var camera_size = get_viewport_rect().size / camera.zoom
		min_bound = camera_center - camera_size / 2
		max_bound = camera_center + camera_size / 2
	else:
		# Use screen bounds
		min_bound = Vector2.ZERO
		max_bound = viewport_rect.size
	
	# Add padding to keep the entire brick visible
	min_bound += shape_extents
	max_bound -= shape_extents
	
	# Clamp position
	var clamped_position = position
	clamped_position.x = clamp(clamped_position.x, min_bound.x, max_bound.x)
	clamped_position.y = clamp(clamped_position.y, min_bound.y, max_bound.y)
	
	return clamped_position
