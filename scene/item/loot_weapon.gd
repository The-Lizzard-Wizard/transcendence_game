extends Area2D

@export var weapon_id : int = 1

func _on_body_entered(body: Node2D) -> void:
	GlobalEvent.enter_loot_zone.emit(weapon_id, get_instance_id())


func _on_body_exited(body: Node2D) -> void:
	GlobalEvent.exit_loot_zone.emit()

func _ready() -> void:
	$Sprite2D.texture = load(WeaponData.weapon_data[weapon_id][3])
