# Ziyan Hirani
# CSC 480
# This script controls the behavior of the "score zone" or trigger region
# that moves across the screen. When the Dino passes it, the player earns
# points and coins. If the Dino collides with it directly, the Dino dies.

extends Area2D

@export var move_speed := 350.0  # Speed at which this zone moves left across the screen
var counted := false              # Ensures the score is only counted once per zone

func _ready() -> void:
	# Connect the built-in body_entered signal to detect collisions with the Dino
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the zone left every frame to match the speed of obstacles
	position.x -= move_speed * delta

	# Check if the Dino has passed this zone without dying
	if not counted:
		var dino = get_parent().get_node("Dino")  # Access the Dino node from the parent scene

		# Once the zone moves past the Dino's x-position, count the score
		if position.x < dino.position.x:
			counted = true               # Prevents counting multiple times
			get_parent().score += 1      # Increase the player's score
			Utils.add_coins(1)           # Add 1 coin to the player's saved total
			print("Score: ", get_parent().score)

	# Remove this zone when it moves far enough off-screen to the left
	if position.x < -600:
		queue_free()

	# Request redraw for debugging or visual updates (if enabled)
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	# If the Dino collides with this zone, trigger its death behavior
	# The "die" method is defined in the Dino script
	if body.has_method("die"):
		body.die()
