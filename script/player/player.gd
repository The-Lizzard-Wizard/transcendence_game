extends Node2D

@export var speed : float = 300


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta):
	var vel = Vector2.ZERO
	look_at(get_global_mouse_position())
	#rotation = rotation
	
	#======================================================================================
	#CAMERA
	#======================================================================================
	var posA = position
	var posB = get_global_mouse_position()
	
	var posC = Vector2.ZERO
	posC.x = (posA.x + posB.x) / 2
	posC.y = (posA.y + posB.y) / 2
	
	var max_rad : float = 500
	var dist = sqrt(pow(posB.x - posA.x,2) + pow(posB.y - posA.y, 2))
	var distC = sqrt(pow(posC.x - posA.x,2) + pow(posC.y - posA.y, 2))
	if (distC > max_rad):
		var posD = Vector2.ZERO
		posD.x = posA.x + max_rad / dist * (posB.x - posA.x)
		posD.y = posA.y + max_rad / dist * (posB.y - posA.y)
		$Camera2D.global_position = posD
	else:
		$Camera2D.global_position = posC
	
	#======================================================================================
	#CONTROL
	#======================================================================================
	#MOVEMENT
	if not Input.is_action_pressed("move"):
		$CharacterBody2D/AnimatedSprite2D.play("idle")
	if Input.is_action_pressed("up"):
		vel.y -= 1
		$CharacterBody2D/AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("down"):
		vel.y += 1
		$CharacterBody2D/AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("right"):
		vel.x += 1
		$CharacterBody2D/AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("left"):
		vel.x -= 1
		$CharacterBody2D/AnimatedSprite2D.play("walk")


	#SHOOT
	if Input.is_action_just_pressed("shoot"):
		print("shoot")
		var shoot = load("res://scene/item/ray_bullet.tscn")
		var shoot_ins : Node2D = shoot.instantiate()
		shoot_ins.position = position
		var ray: RayCast2D = shoot_ins.get_node("RayCast2D")
		var dir = (get_global_mouse_position() - ray.global_position).normalized()
		ray.target_position = ray.to_local(ray.global_position + dir * shoot_ins.range)
		
		var part: GPUParticles2D = ray.get_node("GPUParticles2D")
		part.look_at(get_global_mouse_position())

		get_tree().current_scene.add_child(shoot_ins)
		
		
	if vel.length() > 0:
		vel = vel.normalized() * speed
		
	position += vel * delta
