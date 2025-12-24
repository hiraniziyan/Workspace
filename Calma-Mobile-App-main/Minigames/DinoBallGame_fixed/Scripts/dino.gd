# Ziyan Hirani
# CSC 480
#  his script controls the Dino's movement, jumping, gravity, and death signal logic.

extends CharacterBody2D

const GRAVITY := 2000.0         # Downward force applied every frame
const JUMP_SPEED := -900.0      # Upward velocity applied when the Dino jumps
const GROUND_Y := 260.0         # Fixed Y-position representing the ground level

var velocity_y := 0.0           # Vertical velocity of the Dino
var frozen := false             # When true, the Dino stops moving (e.g., after death)
signal died                     # Signal emitted when the Dino dies

func _ready() -> void:
	# Ensure the Dino is visible when the scene loads
	visible = true
	

func _physics_process(delta: float) -> void:
	# Stop all movement if the Dino is frozen (usually after game-over)
	if frozen:
		return

	# Handle jump input: spacebar / up arrow / left mouse click
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Only allow jumping if the Dino is standing on the ground
		if _is_on_ground():
			velocity_y = JUMP_SPEED

	# Apply gravity every frame to simulate falling
	velocity_y += GRAVITY * delta

	# Update vertical position based on velocity
	position.y += velocity_y * delta

	# Prevent the Dino from falling below the ground
	if position.y > GROUND_Y:
		position.y = GROUND_Y
		velocity_y = 0.0   # Reset velocity when landing

	# Request redraw (useful if you add animations or debug visuals)
	queue_redraw()

func _is_on_ground() -> bool:
	# Checks if the Dino is close enough to the ground to be considered "standing"
	return abs(position.y - GROUND_Y) < 0.5



func die() -> void:
	# Emit a signal so the main scene can respond to the Dino's death
	emit_signal("died")
