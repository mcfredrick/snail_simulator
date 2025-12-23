extends Node2D

# Preload scenes
const SNAIL_SCENE = preload("res://scenes/Player/Snail.tscn")
const MOBILE_CONTROLS_SCENE = preload("res://scenes/UI/MobileControls.tscn")

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
    
func start_game():
    if game_started:
        return
        
    game_started = true
    $UI/TitleScreen.visible = false
    
    # Create player
    spawn_player()
    
    # Set up mobile controls if on mobile
    if OS.has_feature("mobile"):
        setup_mobile_controls()

func setup_input_actions():
    # Set up input map for keyboard controls
    var input_map = {
        "move_up": [KEY_W, KEY_UP],
        "move_down": [KEY_S, KEY_DOWN],
        "move_left": [KEY_A, KEY_LEFT],
        "move_right": [KEY_D, KEY_RIGHT]
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
    # Add mobile controls
    mobile_controls = MOBILE_CONTROLS_SCENE.instantiate()
    add_child(mobile_controls)
    
    # Connect joystick signal to player
    if player and mobile_controls:
        mobile_controls.connect("joystick_moved", Callable(player, "_on_joystick_use_move_vector"))

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
