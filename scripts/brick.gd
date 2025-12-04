extends RigidBody2D

var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	input_pickable = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action("left_click"):
		if event.is_pressed():
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
			freeze = true
		else:
			dragging = false
			freeze = false

func _physics_process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
