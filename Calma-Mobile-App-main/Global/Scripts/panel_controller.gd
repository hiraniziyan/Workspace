# Author: Rajwol Chapagain

extends Control

# Highly fragile code. Its caller needs to know the correct_index for the scene
# it wants to switch to. Moreover, it assumes that Buttons will contain Button
# nodes whose script implements the switchScene method.
func switch_to_scene(scene_index: int) -> void:
	%Buttons.get_child(scene_index).switchScene()
