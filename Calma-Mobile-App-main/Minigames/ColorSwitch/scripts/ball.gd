# ---------------------------------------------------------
# Author: Ziyan Hirani
# Course: CSC 480
# Script: Ball / Player Logic for Color Wheel Game
# ---------------------------------------------------------
extends CharacterBody2D
# This script controls the ball in the Color Wheel game.
# It handles gravity, jumping, color randomization, drawing,
# and notifying the main scene when the player dies.

const G = 1200.0          # Downward gravitational force applied each frame
const J = -300.0          # Jump impulse applied when clicking

var colors = [
	Color(1,0.27,0.6),  # Pink
	Color(0,0.9,1),      # Cyan
	Color(1,0.9,0),      # Yellow
	Color(0.6,0.3,1)     # Purple
]
# Available colors for both drawing and collision logic

var color_index = 0       # Tracks the ball’s current color
var radius = 16.0         # Radius of the circle drawn for the ball
signal died               # Emitted when the ball loses (incorrect color hit, etc.)

func _ready():
	# Initialize collision layers to detect obstacles of matching color
	collision_layer = 1
	collision_mask = 1

	randomize()           # Seed RNG so color changes are unpredictable
	set_color()           # Choose an initial random color

	queue_redraw()        # Request a visual redraw for the ball

func set_color():
	# Assign a new random color from the list
	color_index = randi() % colors.size()
	queue_redraw()        # Redraw ball with updated color

func _physics_process(d):
	# Apply gravity each frame
	velocity.y += G * d

	# Jump when the player clicks the mouse
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		velocity.y = J

	# Apply built-in Godot movement/slide logic
	move_and_slide()

func _draw():
	# Draw the circular ball at the origin of the node
	draw_circle(Vector2.ZERO, radius, colors[color_index])

func die():
	# Emit death signal so the main scene can handle game-over logic
	emit_signal("died")
