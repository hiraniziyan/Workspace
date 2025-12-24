# ---------------------------------------------------------
# Author: Ziyan Hirani
# Course: CSC 480
# Script: Wheel (Rotating Obstacle) for Color Switch Game
# ---------------------------------------------------------
extends Node2D
# This script controls the rotation of the wheel composed of arc segments.
# The wheel rotates continuously and serves as the main obstacle the player
# must navigate through by matching colors.

@export var rotation_speed:float = 60.0
# Rotation speed in degrees per second. A higher value means faster spin.

func _process(d):
	# Rotate the wheel every frame based on the delta time
	rotation_degrees += rotation_speed * d
