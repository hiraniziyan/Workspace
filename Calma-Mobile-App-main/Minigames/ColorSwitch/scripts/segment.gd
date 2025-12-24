# ---------------------------------------------------------
# Author: Ziyan Hirani
# Course: CSC 480
# Script: Segment (Obstacle Arc) for Color Switch Game
# ---------------------------------------------------------
extends Area2D
# This script represents one colored arc segment of a rotating wheel.
# The segment is drawn manually, given a collision shape, and checks
# whether the player's ball matches its color. If not, the ball dies.

@export var color_index:int = 0          # Which color from COLORS this segment uses
@export var start_angle:float = 0.0      # Starting angle of the arc (in degrees)
@export var end_angle:float = 90.0       # Ending angle of the arc (in degrees)
@export var radius:float = 120.0         # Outer radius of the arc
@export var thickness:float = 20.0       # Arc thickness (distance between inner & outer radius)

const COLORS = [
	Color(1,0.27,0.6),  # Pink
	Color(0,0.9,1),     # Cyan
	Color(1,0.9,0),     # Yellow
	Color(0.6,0.3,1)    # Purple
]

func _ready():
	# Set collision layers for interacting only with the ball
	collision_layer = 1
	collision_mask = 1

	# Connect signal to detect when the ball touches this arc
	body_entered.connect(_hit)

	# Create the collision polygon to match the arc's shape
	_generate_collision()

	# Request a redraw for the visual arc
	queue_redraw()

func _draw():
	# Draw the arc segment visually
	_draw_arc(start_angle, end_angle, radius, thickness, COLORS[color_index])

func _draw_arc(a1, a2, r, t, col):
	# Helper function to draw a thick arc using a polygon
	var pts = []
	var inner = r - t       # Inner radius of the arc
	var steps = 40          # Number of segments for smooth curve

	# Outer edge (from a1 → a2)
	for i in range(steps + 1):
		var tt = i / float(steps)
		var ang = deg_to_rad(lerp(a1, a2, tt))
		pts.append(Vector2(cos(ang), sin(ang)) * r)

	# Inner edge (from a2 → a1)
	for i in range(steps + 1):
		var tt = 1.0 - i / float(steps)
		var ang = deg_to_rad(lerp(a1, a2, tt))
		pts.append(Vector2(cos(ang), sin(ang)) * (r - t))

	# Draw the arc as a filled polygon
	draw_polygon(pts, [col])

func _generate_collision():
	# Create a collision polygon that matches the arc’s shape
	var pts = []
	var steps = 40
	var inner = radius - thickness

	# Outer curve (clockwise)
	for i in range(steps + 1):
		var tt = 1.0 - i / float(steps)
		var ang = deg_to_rad(lerp(start_angle, end_angle, tt))
		pts.append(Vector2(cos(ang), sin(ang)) * radius)

	# Inner curve (clockwise)
	for i in range(steps + 1):
		var tt = i / float(steps)
		var ang = deg_to_rad(lerp(start_angle, end_angle, tt))
		pts.append(Vector2(cos(ang), sin(ang)) * inner)

	# Create and assign the collision polygon
	var poly = CollisionPolygon2D.new()
	poly.polygon = pts
	add_child(poly)

func _hit(body):
	# If the player touches this arc and their color does NOT match the arc's color,
	# the ball dies.
	if body.has_method("die"):
		if body.color_index != color_index:
			body.die()
