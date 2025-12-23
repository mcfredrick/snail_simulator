extends Control

# Signal to communicate joystick movement to the player
signal joystick_moved(move_vector)

# Joystick properties
@onready var joystick = $Joystick
var joystick_active: bool = false
var joystick_radius: float = 100.0
var joystick_knob_radius: float = 40.0
var joystick_knob_position: Vector2 = Vector2(50, 50)

# Called when the node enters the scene tree
func _ready():
    # Only show on mobile devices
    if not OS.has_feature("mobile"):
        queue_free()
        return
    
    # Set up joystick appearance
    update_joystick_visuals()

# Handle touch input
func _input(event: InputEvent) -> void:
    if not OS.has_feature("mobile"):
        return
        
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        var touch_pos: Vector2 = event.position
        
        # Check if touch is within joystick area
        if event.pressed and (joystick.get_global_rect().has_point(touch_pos) or joystick_active):
            joystick_active = true
            var joystick_center = joystick.global_position + joystick.pivot_offset
            var move_vector = (touch_pos - joystick_center).limit_length(joystick_radius)
            
            # Update joystick position
            joystick.position = touch_pos - joystick.pivot_offset - move_vector.normalized() * joystick_knob_radius
            
            # Emit the move vector (normalized)
            var normalized_move = move_vector / joystick_radius
            emit_signal("joystick_moved", normalized_move)
            
            get_viewport().set_input_as_handled()
        
        # Handle touch release
        if not event.pressed and joystick_active:
            joystick_active = false
            reset_joystick()
            emit_signal("joystick_moved", Vector2.ZERO)
            get_viewport().set_input_as_handled()

# Reset joystick to initial position
func reset_joystick() -> void:
    joystick.position = Vector2(20, size.y / 2 - joystick_knob_radius)

# Update joystick visual elements
func update_joystick_visuals() -> void:
    # This would be where you set up the visual appearance of the joystick
    # For now, we'll use a simple colored rect for the joystick base and knob
    var joystick_base = ColorRect.new()
    joystick_base.name = "Base"
    joystick_base.color = Color(1, 1, 1, 0.3)
    joystick_base.size = Vector2(joystick_radius * 2, joystick_radius * 2)
    joystick_base.position = -joystick_knob_position
    
    var joystick_knob = ColorRect.new()
    joystick_knob.name = "Knob"
    joystick_knob.color = Color(1, 1, 1, 0.6)
    joystick_knob.size = Vector2(joystick_knob_radius * 2, joystick_knob_radius * 2)
    joystick_knob.position = -Vector2(joystick_knob_radius, joystick_knob_radius)
    
    joystick.add_child(joystick_base)
    joystick.add_child(joystick_knob)
    joystick.pivot_offset = Vector2(joystick_knob_radius, joystick_knob_radius)
    reset_joystick()
