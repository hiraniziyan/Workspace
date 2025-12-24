# ---------------------------------------------------------
# Author: Ziyan Hirani
# Course: CSC 480
# Script: Score Zone for Color Switch Game
# ---------------------------------------------------------
extends Area2D
# This script represents the "score zone," a region the ball
# must pass through to earn a point. When the ball crosses it,
# this zone emits a scoring signal and removes itself.

signal scored                 # Signal emitted when the player earns a point
var triggered = false         # Ensures the zone only scores once

func _ready():
	# Set collision layer/mask so the ball can detect this zone
	collision_layer = 1
	collision_mask = 1

	# Connect to the built-in Area2D body_entered signal
	body_entered.connect(_hit)

func _hit(body):
	# Prevent scoring multiple times from repeated collisions
	if triggered:
		return

	# Only score if the entering body is the player ball
	if body is CharacterBody2D:
		triggered = true            # Mark that scoring has occurred
		emit_signal("scored")       # Notify the main script to increase score
		queue_free()                # Remove this score zone after use
