extends Area2D

@export var color_variation: float = 0.1
var color: Color = Color.WHITE

func _ready() -> void:
    # Generate a random color from the rainbow
    var hue = randf()  # 0.0 to 1.0 for full color spectrum
    var saturation = 0.8 + randf() * 0.2  # 0.8-1.0 for vibrant colors
    var value = 0.8 + randf() * 0.2  # 0.8-1.0 for bright colors
    color = Color.from_hsv(hue, saturation, value)
    
    # Apply color to the flower
    $FlowerSprite.modulate = color
    
    # Add a small random rotation for variety
    rotation = randf() * TAU
    
    # Connect the body_entered signal from the Area2D using call_deferred
    call_deferred("connect", "body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
    if body.has_method("set_color"):
        body.set_color(color)
        queue_free()  # Remove the flower when eaten
