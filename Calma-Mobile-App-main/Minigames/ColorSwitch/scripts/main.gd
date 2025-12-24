# ---------------------------------------------------------
# Author: Ziyan Hirani
# Course: CSC 480
# Script: Main Controller for Color Switch Game
# ---------------------------------------------------------
extends Node2D
# This script manages gameplay for the Color Switch game.
# It handles spawning wheels, score zones, color changers,
# tracking the player’s progress, updating the camera,
# detecting death, and restarting the game.

@onready var ball = $Ball                           # The player-controlled ball
@onready var cam = $Camera2D                        # Camera that follows the ball
@onready var score_label = $CanvasLayer/ScoreLabel  # UI score display
@onready var game_label = $CanvasLayer/GameOverLabel # "Game Over" text

var wheel_scene = preload("res://Minigames/ColorSwitch/Scenes/Wheel.tscn")           # Rotating obstacle
var change_scene = preload("res://Minigames/ColorSwitch/Scenes/ColorChanger.tscn")    # Color changer pickup
var zone_scene = preload("res://Minigames/ColorSwitch/Scenes/ScoreZone.tscn")         # Scoring region

var next_y                                       # Y-position where next wheel will spawn
var spacing = 450                                 # Vertical spacing between wheels
var score = 0                                      # Player score
var dead = false                                   # True when the player dies

func _ready():
	# Initialize starting positions
	ball.position = Vector2(0, 200)
	cam.position = ball.position
	next_y = ball.position.y - 250

	# Pre-spawn several wheels so the level begins already populated
	for i in range(4):
		_spawn()

	# Connect death signal from the ball
	ball.died.connect(_die)

	game_label.visible = false   # Hide the game over message at start
	_update_score()              # Display initial score

func _spawn():
	# Spawn a rotating wheel obstacle
	var w = wheel_scene.instantiate()
	w.position = Vector2(0, next_y)
	add_child(w)

	# Spawn a color changer below the wheel
	var c = change_scene.instantiate()
	c.position = w.position + Vector2(0, 220)
	add_child(c)

	# Spawn a scoring zone above the wheel
	var z = zone_scene.instantiate()
	z.position = w.position + Vector2(0, -260)
	z.scored.connect(_score)    # Increase score when the ball passes through
	add_child(z)

	# Move the next spawn point upward
	next_y -= spacing

func _process(d):
	# Handle restart if player already died
	if dead:
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_parent().add_child(load("res://Minigames/ColorSwitch/Scenes/Main.tscn").instantiate())
			queue_free()
		
	# Make the camera follow the ball upward
	if ball.position.y < cam.position.y:
		cam.position.y = ball.position.y

	# Spawn new obstacles when the camera gets close to the top of the spawn area
	if cam.position.y - next_y < 800:
		_spawn()

	# Detect falling off the screen
	if ball.position.y > cam.position.y + 600:
		_die()

func _score():
	# Increase score only if player is alive
	if dead: return
	score += 1

	# Add coins to the global save system
	Utils.add_coins(1)

	_update_score()   # Refresh score UI

func _update_score():
	# Display score on the label
	score_label.text = str(score)

func _die():
	# Prevent multiple death triggers
	if dead: return

	dead = true
	game_label.visible = true   # Show "Game Over" text
