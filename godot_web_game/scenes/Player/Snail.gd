extends CharacterBody2D

# -------------------------------------------------------------------------
#  CONFIGURATION
# -------------------------------------------------------------------------
@export var speed:               float = 200.0
@export var rotation_speed:     float = 5.0
@export var trail_scene:        PackedScene
@export var scale_factor:       float = 2.0

# -------------------------------------------------------------------------
#  STATE
# -------------------------------------------------------------------------
var trail:          Node2D   = null
var current_color: Color    = Color.WHITE

# -------------------------------------------------------------------------
#  READY
# -------------------------------------------------------------------------
func _ready() -> void:
    randomize()
    _create_colors()
    _build_body()
    _build_shell()
    _add_eyes()
    call_deferred("spawn_trail")


# -------------------------------------------------------------------------
#  COLOR SETUP
# -------------------------------------------------------------------------
func _create_colors() -> void:
    var shell_color = Color.from_hsv(randf(), 0.8, 0.9)
    var body_color  = shell_color.inverted()
    current_color   = shell_color

    if has_node("ColorRect"):
        $ColorRect.queue_free()


# -------------------------------------------------------------------------
#  BODY – elongated slug-like body with head and tail
# -------------------------------------------------------------------------
func _build_body() -> void:
    var body = Polygon2D.new()
    var body_points = PackedVector2Array()
    
    # Body extends from back (negative X) to front (positive X)
    # Tail is narrow, wide in middle under shell, head/front is smaller
    var length = 70.0 * scale_factor
    var segments = 50
    
    # Top half of body outline
    for i in range(segments + 1):
        var t = i / float(segments)
        var x = lerp(-length * 0.4, length * 0.6, t)  # tail to head
        
        # Width varies: very narrow tail, wide middle, smaller head
        var width_factor: float
        if t < 0.25:  # tail section - taper from point to wide
            width_factor = lerp(0.05, 1.0, t / 0.25)
        elif t < 0.6:  # middle section (under shell) - full width
            width_factor = 1.0
        else:  # head/neck section - narrows significantly
            width_factor = lerp(1.0, 0.35, (t - 0.6) / 0.4)
        
        var y = -8.0 * scale_factor * width_factor
        body_points.append(Vector2(x, y))
    
    # Bottom half (reverse direction)
    for i in range(segments, -1, -1):
        var t = i / float(segments)
        var tail_loc = 0.5
        var middle_loc = 0.6
        var x = lerp(-length * 0.4, length * 0.6, t)
        var max_width_factor = 0.6
        var min_width_factor = 0.1
        
        var width_factor: float
        if t < tail_loc:  # tail section
            width_factor = lerp(min_width_factor, max_width_factor, t / tail_loc)
        elif t < middle_loc:  # middle section
            width_factor = max_width_factor
        else:  # head/neck section
            width_factor = lerp(max_width_factor, 0.35, (t - middle_loc) / (1.0 - middle_loc))
        
        var y = 8.0 * scale_factor * width_factor
        body_points.append(Vector2(x, y))
    
    body.polygon = body_points
    body.color = current_color.inverted()
    body.z_index = -1
    add_child(body)
    
    # Add a smaller head bump
    var head = Polygon2D.new()
    var head_points = PackedVector2Array()
    var head_center_x = length * 0.55
    var head_radius = 4.5 * scale_factor  # smaller head
    
    for i in range(16):
        var angle = lerp(0.0, TAU, i / 15.0)
        var x = head_center_x + cos(angle) * head_radius * 1.0
        var y = sin(angle) * head_radius * 0.7  # slightly flatter
        head_points.append(Vector2(x, y))
    
    head.polygon = head_points
    head.color = current_color.inverted().lightened(0.1)
    head.z_index = 0
    add_child(head)


# -------------------------------------------------------------------------
#  SHELL – spiral positioned on the back middle section
# -------------------------------------------------------------------------
func _build_shell() -> void:
    var shell_container = Node2D.new()
    shell_container.position = Vector2(7.0 * scale_factor, scale_factor * -9.0)  # slightly back from center
    add_child(shell_container)
    
    var shell = Polygon2D.new()
    var shell_points = PackedVector2Array()
    
    # Create spiral from outside to center
    var turns = 2.8
    var segments = 100
    
    for i in range(segments):
        var t = i / float(segments - 1)
        # Spiral inward with opening facing forward (right side)
        var angle = t * TAU * turns  # Removed the PI offset to rotate opening forward
        var radius = lerp(20.0 * scale_factor, 2.0 * scale_factor, pow(t, 0.8))
        
        var x = cos(angle) * radius
        var y = sin(angle) * radius
        shell_points.append(Vector2(x, y))
    
    shell.polygon = shell_points
    shell.color = current_color.darkened(0.3)
    shell.z_index = 1
    shell_container.add_child(shell)
    
    # Inner rings for depth
    for ring in range(3):
        var inner = Polygon2D.new()
        var inner_pts = PackedVector2Array()
        var inner_radius = lerp(14.0, 4.0, ring / 2.0) * scale_factor
        var inner_segs = 24
        
        for i in range(inner_segs):
            var a = i / float(inner_segs) * TAU
            inner_pts.append(Vector2(cos(a), sin(a)) * inner_radius)
        
        inner.polygon = inner_pts
        inner.color = current_color.lightened(0.05 * (ring + 1))
        inner.z_index = 2 + ring
        shell_container.add_child(inner)


# -------------------------------------------------------------------------
#  EYES – stalks pointing upward and forward from the head
# -------------------------------------------------------------------------
func _add_eyes() -> void:
    var head_x = 35.0 * scale_factor  # adjusted for smaller head
    
    var create_eye_stalk = func(y_offset: float, lean_angle: float):
        var stalk_container = Node2D.new()
        stalk_container.position = Vector2(head_x, y_offset)
        stalk_container.rotation = lean_angle
        add_child(stalk_container)
        
        # Stalk - tapered tube pointing upward
        var stalk = Polygon2D.new()
        var stalk_points = PackedVector2Array()
        var stalk_length = 12.0 * scale_factor
        var base_width = 2.5 * scale_factor
        var tip_width = 1.5 * scale_factor
        
        # Left side going up
        stalk_points.append(Vector2(-base_width/2, 0))
        stalk_points.append(Vector2(-tip_width/2, -stalk_length))
        # Right side coming down
        stalk_points.append(Vector2(tip_width/2, -stalk_length))
        stalk_points.append(Vector2(base_width/2, 0))
        
        stalk.polygon = stalk_points
        stalk.color = current_color.inverted().darkened(0.15)
        stalk.z_index = 3
        stalk_container.add_child(stalk)
        
        # Eyeball at tip
        var eye = Polygon2D.new()
        var eye_points = PackedVector2Array()
        var eye_radius = 4.0 * scale_factor
        var eye_segments = 16
        
        for i in range(eye_segments):
            var a = i / float(eye_segments) * TAU
            eye_points.append(Vector2(cos(a), sin(a)) * eye_radius)
        
        eye.polygon = eye_points
        eye.position = Vector2(0, -stalk_length)
        eye.color = Color.BLACK
        eye.z_index = 4
        stalk_container.add_child(eye)
        
        # White highlight
        var highlight = Polygon2D.new()
        var highlight_points = PackedVector2Array()
        var highlight_radius = 1.8 * scale_factor
        for i in range(10):
            var a = i / 10.0 * TAU
            highlight_points.append(Vector2(cos(a), sin(a)) * highlight_radius)
        highlight.polygon = highlight_points
        highlight.position = Vector2(-eye_radius * 0.25, -stalk_length - eye_radius * 0.25)
        highlight.color = Color.WHITE
        highlight.z_index = 5
        stalk_container.add_child(highlight)
    
    var y_offset = 2.0 * scale_factor
    # Create eye stalks leaning slightly forward and outward
    create_eye_stalk.call(-y_offset, -0.15)  # left eye, lean left and forward
    create_eye_stalk.call(y_offset, 0.15)    # right eye, lean right and forward


# -------------------------------------------------------------------------
#  PHYSICS
# -------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
    var input_vec = Vector2.ZERO
    input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input_vec.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")

    # The joystick now directly controls the ui_* actions, so we don't need the joystick_input anymore

    if input_vec.length() > 0.0:
        velocity = input_vec.normalized() * speed
        var target_angle = input_vec.angle()
        rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, speed * delta * 2)

    move_and_slide()


# -------------------------------------------------------------------------
#  TRAIL – spawns behind the snail (at the shell position)
# -------------------------------------------------------------------------
func spawn_trail() -> void:
    if not trail_scene:
        push_error("Trail scene is not set in Snail")
        return

    if trail and is_instance_valid(trail):
        trail.queue_free()

    trail = trail_scene.instantiate()
    if not trail:
        push_error("Failed to instantiate trail")
        return

    var parent = get_parent()
    if not parent:
        push_error("Snail has no parent to add trail to")
        return

    # Add trail as a child of the parent but ensure it's below the snail
    var index = get_index()  # Get current snail's index in parent
    parent.add_child(trail)
    parent.move_child(trail, index)  # Move trail to be right before the snail
    trail.z_index = -1  # Ensure trail is drawn below the snail
    # Position trail at the back (shell center, which is the snail's origin)
    trail.global_position = global_position
    trail.target = self
    trail.set_trail_color(current_color)


# -------------------------------------------------------------------------
#  PUBLIC API
# -------------------------------------------------------------------------
func set_color(col: Color) -> void:
    current_color = col
    if trail and is_instance_valid(trail):
        trail.set_trail_color(col)


# -------------------------------------------------------------------------
#  CLEAN‑UP
# -------------------------------------------------------------------------
func _exit_tree() -> void:
    if trail and is_instance_valid(trail):
        trail.queue_free()