# ---------------------------------------------------------
# Author: Ziyan Hirani
# Course: CSC 480
# Script: Color Changer for Color Wheel Game
# ---------------------------------------------------------
extends Area2D
# This script represents the "color changer" object.
# When the ball touches it, the ball receives a new random color
# and this object removes itself from the scene.

func _ready():
	# Configure collision layers so the ball can detect this object
	collision_layer = 1
	collision_mask = 1

	# Connect the built-in signal to handle when the player touches it
	body_entered.connect(_hit)

	# Request a redraw for the visual circle
	queue_redraw()

func _draw():
	# Draw the color changer as a small white circle
	draw_circle(Vector2.ZERO, 12, Color(1,1,1))

func _hit(body):
	# If the colliding body has a "set_color" function (the ball),
	# then change the ball's color
	if body.has_method("set_color"):
		body.set_color()

	# Remove the color changer after use so it doesn't trigger twice
	queue_free()
