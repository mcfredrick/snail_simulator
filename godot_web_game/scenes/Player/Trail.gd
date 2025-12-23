extends Line2D

@export var max_points: int = 100
@export var min_distance: float = 5.0
@export var trail_width: float = 16.0

var target: Node2D = null
var current_color: Color = Color.WHITE
var is_active: bool = true

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
        return
    
    # Always update the first point to be exactly at the target's position
    set_point_position(0, local_target_pos)
    
    # Add a new point if we've moved enough distance from the last point
    if get_point_count() < 2 or local_target_pos.distance_to(get_point_position(1)) >= min_distance:
        add_point(local_target_pos, 1)


func set_trail_color(color: Color) -> void:
    current_color = color
    default_color = color
    if gradient:
        gradient = null

func clear_trail() -> void:
    clear_points()