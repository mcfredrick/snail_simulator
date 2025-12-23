extends Area2D

# -------------------------------------------------------------------------
#  CONFIGURATION
# -------------------------------------------------------------------------
@export var scale_factor: float = 2.0  # overall size multiplier
@export var color_variation: float = 0.1

# -------------------------------------------------------------------------
#  STATE
# -------------------------------------------------------------------------
var color: Color = Color.WHITE

# -------------------------------------------------------------------------
#  READY
# -------------------------------------------------------------------------
func _ready() -> void:
    randomize()
    
    # Generate a random color from the rainbow (from your existing code)
    var hue = randf()  # 0.0 to 1.0 for full color spectrum
    var saturation = 0.8 + randf() * 0.2  # 0.8-1.0 for vibrant colors
    var value = 0.8 + randf() * 0.2  # 0.8-1.0 for bright colors
    color = Color.from_hsv(hue, saturation, value)
    
    # Build the flower sprite
    _build_flower_sprite()
    
    # Add a small random rotation for variety
    rotation = randf() * TAU
    
    # Update collision shape
    _update_collision()
    
    # Connect the body_entered signal from the Area2D
    body_entered.connect(_on_body_entered)


# -------------------------------------------------------------------------
#  BUILD FLOWER SPRITE
# -------------------------------------------------------------------------
func _build_flower_sprite() -> void:
    # Find or create FlowerSprite node
    var flower_sprite = null
    if has_node("FlowerSprite"):
        flower_sprite = $FlowerSprite
        # Clear existing children
        for child in flower_sprite.get_children():
            child.queue_free()
    else:
        flower_sprite = Node2D.new()
        flower_sprite.name = "FlowerSprite"
        add_child(flower_sprite)
    
    _build_stem(flower_sprite)
    _build_petals(flower_sprite)
    _build_center(flower_sprite)


# -------------------------------------------------------------------------
#  STEM
# -------------------------------------------------------------------------
func _build_stem(parent: Node2D) -> void:
    var stem = Polygon2D.new()
    var stem_points = PackedVector2Array()
    
    var stem_width = 2.0 * scale_factor
    var stem_height = 20.0 * scale_factor
    
    # Simple rectangular stem extending downward
    stem_points.append(Vector2(-stem_width/2, 0))
    stem_points.append(Vector2(stem_width/2, 0))
    stem_points.append(Vector2(stem_width/2, stem_height))
    stem_points.append(Vector2(-stem_width/2, stem_height))
    
    stem.polygon = stem_points
    stem.color = Color(0.2, 0.6, 0.2, 1)  # green
    stem.z_index = -2
    parent.add_child(stem)


# -------------------------------------------------------------------------
#  PETALS - arranged in a circle like a daisy
# -------------------------------------------------------------------------
func _build_petals(parent: Node2D) -> void:
    var num_petals = 8
    var petal_length = 12.0 * scale_factor
    var petal_width = 6.0 * scale_factor
    
    for i in range(num_petals):
        var angle = (i / float(num_petals)) * TAU
        
        var petal = Polygon2D.new()
        var petal_points = PackedVector2Array()
        
        # Create an oval/ellipse petal shape
        var segments = 16
        for j in range(segments):
            var t = j / float(segments - 1)
            var petal_angle = lerp(-PI, PI, t)
            
            # Ellipse: longer in one direction, shorter in the other
            var x = cos(petal_angle) * petal_length
            var y = sin(petal_angle) * petal_width / 2.0
            
            petal_points.append(Vector2(x, y))
        
        petal.polygon = petal_points
        petal.color = color
        petal.rotation = angle
        petal.z_index = -1
        
        parent.add_child(petal)
        
        # Add a subtle highlight to each petal
        var petal_highlight = Polygon2D.new()
        var highlight_points = PackedVector2Array()
        
        for j in range(segments):
            var t = j / float(segments - 1)
            var petal_angle = lerp(-PI, PI, t)
            
            # Smaller highlight in the center of the petal
            var x = cos(petal_angle) * petal_length * 0.6
            var y = sin(petal_angle) * petal_width / 3.0
            
            highlight_points.append(Vector2(x, y))
        
        petal_highlight.polygon = highlight_points
        petal_highlight.color = color.lightened(0.3)
        petal_highlight.rotation = angle
        petal_highlight.z_index = 0
        parent.add_child(petal_highlight)


# -------------------------------------------------------------------------
#  CENTER - circular center of the flower
# -------------------------------------------------------------------------
func _build_center(parent: Node2D) -> void:
    var center = Polygon2D.new()
    var center_points = PackedVector2Array()
    var center_radius = 5.0 * scale_factor
    var segments = 20
    
    for i in range(segments):
        var angle = (i / float(segments)) * TAU
        var x = cos(angle) * center_radius
        var y = sin(angle) * center_radius
        center_points.append(Vector2(x, y))
    
    center.polygon = center_points
    center.color = Color(0.9, 0.7, 0.1, 1)  # yellow/golden center
    center.z_index = 1
    parent.add_child(center)
    
    # Add texture to center with small dots
    for i in range(12):
        var dot = Polygon2D.new()
        var dot_points = PackedVector2Array()
        var dot_radius = 0.8 * scale_factor
        
        for j in range(8):
            var angle = (j / 8.0) * TAU
            dot_points.append(Vector2(cos(angle), sin(angle)) * dot_radius)
        
        dot.polygon = dot_points
        dot.position = Vector2(
            randf_range(-center_radius * 0.6, center_radius * 0.6),
            randf_range(-center_radius * 0.6, center_radius * 0.6)
        )
        dot.color = Color(0.7, 0.5, 0.05, 1)  # darker dots
        dot.z_index = 2
        parent.add_child(dot)


# -------------------------------------------------------------------------
#  COLLISION - update based on scale
# -------------------------------------------------------------------------
func _update_collision() -> void:
    # Find or create collision shape
    var collision_shape = null
    for child in get_children():
        if child is CollisionShape2D:
            collision_shape = child
            break
    
    if not collision_shape:
        collision_shape = CollisionShape2D.new()
        add_child(collision_shape)
    
    # Create circular collision shape that matches flower size
    var shape = CircleShape2D.new()
    shape.radius = 12.0 * scale_factor  # matches petal length
    collision_shape.shape = shape


# -------------------------------------------------------------------------
#  SIGNAL HANDLER (from your existing code)
# -------------------------------------------------------------------------
func _on_body_entered(body: Node) -> void:
    if body.has_method("set_color"):
        body.set_color(color)
        queue_free()  # Remove the flower when eaten