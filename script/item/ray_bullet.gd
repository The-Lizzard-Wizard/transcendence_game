extends Node2D

@export var range : float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$point.position = $RayCast2D.target_position
	$RayCast2D/GPUParticles2D.process_material.emission_box_extents.x = range
	$RayCast2D/GPUParticles2D.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
