extends Button

@onready var scene_container:Node = $"../../../../ActiveScene"
@export var panel:String = "res://Minigames/DinoBallGame_fixed/Scenes/Main.tscn"

#Add smooth screen transition later
func switchScene():
	#Clear Children in container
	if scene_container.get_child_count() > 0:
		for child in scene_container.get_children():
			child.queue_free()
	
	var panel_load = load(panel)
	var panel_instance = panel_load.instantiate()
	scene_container.add_child(panel_instance)
