extends Node2D

func _process(delta: float) -> void:
	var v : Vector2 = Vector2.ZERO
	v.x = 0.005
	v.y = 0.005
	scale = scale - v

func _on_timer_timeout() -> void:
	queue_free()
