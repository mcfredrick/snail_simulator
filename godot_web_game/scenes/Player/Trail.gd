extends Line2D

@export var max_points: int = 100
@export var min_distance: float = 5.0
@export var trail_width: float = 16.0

var target: Node2D = null
var current_color: Color = Color.WHITE
var is_active: bool = true
var point_colors: Array[Color] = []

func _ready() -> void:
    width = trail_width
    default_color = current_color
    clear_points()
    show()
    z_index = 1
    # Remove top_level since we want to manage position relative to the scene
    top_level = false

func _process(_delta: float) -> void:
    if not is_active or not target or not is_inside_tree():
        return
    
    # Get target position in global space
    var target_pos = target.global_position
    
    # Convert target position to local space
    var local_target_pos = to_local(target_pos)
    
    # If no points, add the first one at the target's position
    if get_point_count() == 0:
        add_point(local_target_pos)
        point_colors.append(current_color)
        update_gradient()
        return
    
    # Always update the first point to be exactly at the target's position
    set_point_position(0, local_target_pos)
    
    # Add a new point if we've moved enough distance from the last point
    if get_point_count() < 2 or local_target_pos.distance_to(get_point_position(1)) >= min_distance:
        add_point(local_target_pos, 1)
        point_colors.insert(1, current_color)
        update_gradient()
    else:
        # Update the first point's color if it changed
        if point_colors[0] != current_color:
            point_colors[0] = current_color
            update_gradient()


func set_trail_color(color: Color) -> void:
    current_color = color
    if point_colors.size() > 0:
        point_colors[0] = color
        update_gradient()

func clear_trail() -> void:
    clear_points()
    point_colors.clear()
    
func update_gradient() -> void:
    var point_count = get_point_count()
    if point_count < 2:
        gradient = null
        return
        
    var new_gradient = Gradient.new()
    new_gradient.offsets = []
    new_gradient.colors = []
    
    for i in range(point_count):
        var offset = float(i) / (point_count - 1) if point_count > 1 else 0.0
        new_gradient.add_point(offset, point_colors[i] if i < point_colors.size() else current_color)
    
    gradient = new_gradient