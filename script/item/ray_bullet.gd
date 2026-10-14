extends Node2D

@export var range : float = 50
var ray2D : RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$point.position = $RayCast2D.target_position
	$RayCast2D/GPUParticles2D.process_material.emission_box_extents.x = range
	$RayCast2D/GPUParticles2D.emitting = true
	ray2D = $RayCast2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (ray2D.is_colliding()):
			var mark = load("res://scene/item/hit_marker.tscn")
			var mark_ins : Node2D = mark.instantiate()
			mark_ins.global_position = ray2D.get_collision_point()
			get_tree().current_scene.add_child(mark_ins)
	free()
