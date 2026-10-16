extends CharacterBody2D

@export var speed : float = 300
@export var healt : int = 100
@export var weapon : int = -1 #weapon id

@export var client_player : bool = true

#=======================================================================
#weapon loot
#=======================================================================
var in_loot_zone = false
var loot_zone_id = 0
var loot_id = 0 #incetance id of the entered loot zone

func player_enter_loot_zone(w_id : int, id : int):
	in_loot_zone = true
	loot_zone_id = w_id
	loot_id = id

func player_exit_loot_zone():
	in_loot_zone = false

func interact_with_loot():
	if (in_loot_zone == true):
		if (Input.is_action_just_pressed("loot")):
			in_loot_zone = false
			
			drop_weapon()
			equip_weapon(loot_zone_id)
			
			var loot_ins = instance_from_id(loot_id)
			loot_ins.free()

#============================================================================
#weapon management
#============================================================================
func equip_weapon(id : int):
	weapon = id
	$hand/Sprite2D.texture = load(WeaponData.weapon_data[weapon][3])

func drop_weapon():
	if (weapon != -1):
		var droped_weapon = load("res://scene/item/loot_weapon.tscn")
		var droped_weapon_ins = droped_weapon.instantiate()
		droped_weapon_ins.weapon_id = weapon
		droped_weapon_ins.position = position
		get_tree().current_scene.add_child(droped_weapon_ins)
		weapon = -1
		$hand/Sprite2D.texture = null

func use_weapon():
	if (weapon != -1):
		var shoot = load("res://scene/item/ray_bullet.tscn")
		var shoot_ins : Node2D = shoot.instantiate()
		shoot_ins.position = position
		shoot_ins.w_range = WeaponData.weapon_data[weapon][1]
		var ray: RayCast2D = shoot_ins.get_node("RayCast2D")
		var dir = (get_global_mouse_position() - ray.global_position).normalized()
		ray.target_position = ray.to_local(ray.global_position + dir * shoot_ins.w_range)
		
		var part: GPUParticles2D = ray.get_node("GPUParticles2D")
		part.look_at(get_global_mouse_position())

		get_tree().current_scene.add_child(shoot_ins)

#===========================================================================
# Called when the node enters the scene tree for the first time.
#===========================================================================
func _ready() -> void:
	GlobalEvent.enter_loot_zone.connect(player_enter_loot_zone)
	GlobalEvent.exit_loot_zone.connect(player_exit_loot_zone)
	if (client_player == false):
		$Camera2D.enabled = false

#===========================================================================
#player physic proc
#===========================================================================
func client_physic_proc(delta):
	
	var vel = Vector2.ZERO
	look_at(get_global_mouse_position())

	#======================================================================================
	#MOVEMENT
	#======================================================================================
	if not Input.is_action_pressed("move"):
		$AnimatedSprite2D.play("idle")
	if Input.is_action_pressed("up"):
		vel.y -= 1
		$AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("down"):
		vel.y += 1
		$AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("right"):
		vel.x += 1
		$AnimatedSprite2D.play("walk")
	if Input.is_action_pressed("left"):
		vel.x -= 1
		$AnimatedSprite2D.play("walk")
	
	if vel.length() > 0:
		vel = vel.normalized()
	
	velocity = (vel * speed)
	move_and_slide()


func client_proc(delta):
	
	#======================================================================================
	#CAMERA
	#======================================================================================
	var posA = global_position
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
	#ACTION
	#======================================================================================
	if Input.is_action_just_pressed("shoot"):
		use_weapon()
	
	if (Input.is_action_just_pressed("drop_weapon")):
		drop_weapon()
	
	interact_with_loot()
	
func not_client_proc(delta):
	pass
	
func _physics_process(delta: float) -> void:
	if client_player == true:
		client_physic_proc(delta)

func _process(delta: float):
	if client_player == true:
		client_proc(delta)
	else:
		not_client_proc(delta)
