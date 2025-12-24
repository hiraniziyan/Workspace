# Ziyan Hirani
# CSC 480
# Main controller script for the Dino game.
# Handles spawning obstacles, updating score, detecting game over,
# and restarting the game.

extends Node2D

@onready var dino = $Dino                                # Reference to the Dino player
@onready var score_label = $CanvasLayer/ScoreLabel       # UI label showing current score
@onready var game_over_label = $CanvasLayer/GameOverLabel # UI label for game-over display

var cactus_scene := preload("res://Minigames/DinoBallGame_fixed/Scenes/Cactus.tscn")
# Preloaded cactus scene for faster instantiation during gameplay

var spawn_timer := 0.0            # Timer to control cactus spawn frequency
var spawn_interval := 1.5         # Initial time between spawns
var min_spawn_interval := 0.7     # Minimum allowed spawn delay (difficulty cap)
var scroll_speed := 350.0         # Speed at which cactuses move leftward
var score := 0.0                  # Player score
var is_game_over := false         # Tracks whether game-over state is active

func _ready() -> void:
	# Initialize game state
	randomize()                    # Random seed for varied spawns if needed
	dino.died.connect(_on_dino_died)  # Connect Dino's death signal
	game_over_label.visible = false   # Hide game-over text until needed

func _physics_process(delta: float) -> void:
	# If the game is over, wait for the player to restart
	if is_game_over:
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_restart()
		return

	# Handle cactus spawning with dynamic difficulty
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_cactus()
		# Gradually reduce spawn interval to increase difficulty
		spawn_interval = max(min_spawn_interval, spawn_interval - 0.03)
		spawn_timer = spawn_interval

	# Update the on-screen score display
	score_label.text = str(int(score))

func _spawn_cactus() -> void:
	# Create and position a new cactus
	print("SPAWNING CACTUS")
	var cactus = cactus_scene.instantiate()
	var ground_y := 240.0                       # Y-position where cactuses should appear
	cactus.position = Vector2(600.0, ground_y)  # Spawn just off-screen on the right
	cactus.move_speed = scroll_speed            # Match main game scroll speed
	add_child(cactus)

func _on_dino_died() -> void:
	# Trigger game-over logic
	is_game_over = true
	dino.frozen = true          # Prevent further player movement

	# Customize and display game-over label
	game_over_label.text = "Game Over"
	game_over_label.add_theme_font_size_override("font_size", 24)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Center the label horizontally on the screen
	var viewport_width := get_viewport_rect().size.x
	game_over_label.position.x = viewport_width / 2.0 - game_over_label.size.x / 2.0

	game_over_label.visible = true

func _restart() -> void:
	# Restart game by loading a fresh instance of the Main scene
	get_parent().add_child(load("res://Minigames/DinoBallGame_fixed/Scenes/Main.tscn").instantiate())
	queue_free()   # Remove the old instance
