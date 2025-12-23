extends Node2D

# Preload scenes
const SNAIL_SCENE = preload("res://scenes/Player/Snail.tscn")
const FLOWER_SCENE = preload("res://scenes/Flower/Flower.tscn")

# Flower spawning
@export var max_flowers: int = 10
@export var spawn_interval: float = 3.0
var flower_timer: float = 0.0
var viewport_rect: Rect2
var margin: float = 50.0

# Game state
var player = null
var mobile_controls = null
var game_started = false

func _ready():
    # Set up the game
    setup_game()
    
    # Set up window size and scaling
    get_tree().set_auto_accept_quit(false)
    
    # Show title screen
    $UI/TitleScreen.visible = true
    
    # Set up input actions
    setup_input_actions()
    
    # Initialize viewport rect
    var viewport_size = get_viewport_rect().size
    viewport_rect = Rect2(margin, margin, viewport_size.x - 2 * margin, viewport_size.y - 2 * margin)
    
func start_game():
    if game_started:
        return
        
    game_started = true
    $UI/TitleScreen.visible = false
    
    # Create player
    spawn_player()
    
    # Set up mobile controls if on mobile
    if DisplayServer.is_touchscreen_available():
        setup_mobile_controls()

func setup_input_actions():
    # Set up input map for keyboard controls
    var input_map = {
        "ui_up": [KEY_W, KEY_UP],
        "ui_down": [KEY_S, KEY_DOWN],
        "ui_left": [KEY_A, KEY_LEFT],
        "ui_right": [KEY_D, KEY_RIGHT]
    }
    
    for action in input_map:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            
        # Clear existing inputs for this action
        for event in InputMap.action_get_events(action):
            InputMap.action_erase_event(action, event)
            
        # Add new inputs
        for key in input_map[action]:
            var event = InputEventKey.new()
            event.keycode = key
            InputMap.action_add_event(action, event)

func setup_game():
    # Set up game window and viewport
    var viewport = get_viewport_rect().size
    $Background.size = viewport
    
    # Set up camera limits
    $Camera2D.limit_left = 0
    $Camera2D.limit_top = 0
    $Camera2D.limit_right = viewport.x
    $Camera2D.limit_bottom = viewport.y

func spawn_player():
    # Create and add player to the scene
    player = SNAIL_SCENE.instantiate()
    player.position = get_viewport_rect().size / 2  # Center of the screen
    add_child(player)
    
    # Make camera follow player
    $Camera2D.position = player.position
    player.connect("tree_exiting", Callable(self, "_on_Player_died"))

func setup_mobile_controls():
    # Create and configure the touch screen joystick
    var joystick = preload("res://addons/touch_screen_joystick/touch_screen_joystick.gd").new()
    
    # Configure joystick properties
    joystick.name = "TouchScreenJoystick"
    joystick.size = Vector2(300, 300)  # Make it a good size for touch
    joystick.position = Vector2(50, get_viewport_rect().size.y - 350)  # Position at bottom left
    joystick.base_radius = 80.0
    joystick.knob_radius = 40.0
    joystick.deadzone = 10.0
    joystick.use_input_actions = true  # This will automatically handle the input actions
    
    # Add to scene
    add_child(joystick)
    mobile_controls = joystick  # Store reference
    
    # The joystick will automatically handle input actions, so we don't need to connect signals

func spawn_flower() -> void:
    var flower = FLOWER_SCENE.instantiate()
    add_child(flower)
    flower.add_to_group("flowers")
    
    # Position the flower randomly within the viewport bounds
    var x = randf_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
    var y = randf_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
    flower.position = Vector2(x, y)
    
    # Add a small random offset to prevent perfect grid alignment
    flower.position += Vector2(randf_range(-20, 20), randf_range(-20, 20))

func _on_Player_died():
    # Handle player death
    print("Player died!")
    # You can add game over logic here
    # For now, just respawn the player
    spawn_player()

func _notification(what):
    # Handle window close event
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit()

func _process(delta):
    # Update camera to follow player
    if player:
        $Camera2D.position = player.position
    
    # Handle flower spawning
    if game_started:
        flower_timer += delta
        if flower_timer >= spawn_interval and get_tree().get_nodes_in_group("flowers").size() < max_flowers:
            flower_timer = 0.0
            spawn_flower()
