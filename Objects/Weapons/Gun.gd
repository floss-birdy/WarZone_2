extends Node2D
class_name Gun

export var gun_type : String = "pistol"
export var gun_name : String = "null"
export var damage : float = 18
export var rounds_in_clip : int = 10
export var clips : int = 4
export var projectile_velocity : float = 700
export var rate_of_fire : float = 4
export var spread : float = 0.1
export var recoil_factor : float = 0.05
export var max_zoom : float = 1.0

var current_zoom : float = 0.75
var projectile = preload("res://Objects/Weapons/Projectile.tscn")
var ready_to_fire : bool = true
var gun_user 
var rounds_left : int
var recoil : float = 0
var reloading : bool = false

var max_ray_distance : float = 200
var ray_dest : Vector2
var laser_sight : bool = true

func _ready():
	rounds_left = rounds_in_clip
	gun_user = get_parent()

##server only
func fireGun():
	if clips <= 0 and rounds_left <= 0:
		if ready_to_fire:
			$clipOut.play()
			ready_to_fire = false
			$Timer.start(1 / rate_of_fire)
		return
	if ready_to_fire and rounds_left > 0:
		_shoot()
	elif rounds_left <= 0:
		if not reloading:
			reload()
			reloading = true


remote func _create_bullet(pos,rot):
	var bullet = projectile.instance()
	bullet.create_bullet(pos,rot,projectile_velocity,damage,self,gun_user)
	get_tree().root.add_child(bullet)
	$fire.play()
	if get_tree().is_network_server():
		rpc("_create_bullet",pos,rot)

func _shoot():
	recoil += recoil_factor
	var angular_spread : float = rand_range(-spread,spread) * ( 1 + recoil)
	if get_tree().is_network_server():
		_create_bullet($Muzzle.global_position,global_rotation + angular_spread)
	else:
		rpc_id(1,"_create_bullet",$Muzzle.global_position,global_rotation + angular_spread)
	ready_to_fire = false
	$Timer.start(1 / rate_of_fire)
	rounds_left -= 1
	$recoil_cool.start()



func _on_Timer_timeout():
	ready_to_fire = true

func reload():
	if clips > 0 and not reloading:
		$Reload_time.start()
		reloading = true

func _on_Reload_time_timeout():
	clips -= 1
	rounds_left = rounds_in_clip
	reloading = false


func _on_recoil_cool_timeout():
	recoil = 0

var target : bool = false

func _process(delta):
	if not laser_sight:
		return
	target = false
	ray_dest = $RayCast2D.cast_to
	if $RayCast2D.is_colliding():
		ray_dest = $RayCast2D.get_collision_point()
		target = true
	update()




func _draw():
	if not target:
		draw_line($Muzzle.position, ray_dest, Color.red)
		draw_circle(ray_dest, 3, Color.red)
	else:
		draw_line($Muzzle.position, (ray_dest - $RayCast2D.global_position).rotated(-global_rotation), Color.red)
		draw_circle((ray_dest - $RayCast2D.global_position).rotated(-global_rotation), 3, Color.red)