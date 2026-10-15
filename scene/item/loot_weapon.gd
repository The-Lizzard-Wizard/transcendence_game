extends Node2D

@export var weapon_id : int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D/Sprite2D.texture = load(WeaponData.weapon_data[weapon_id][3])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
