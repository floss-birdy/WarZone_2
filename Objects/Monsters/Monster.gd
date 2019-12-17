extends "res://Objects/Character.gd"

class_name Monster

export var rotational_speed : float = 2
export var main_destination : Vector2
export var damage : float = 10
export var attack_radius : float = 10

var path_array : PoolVector2Array 
var nav : Navigation2D
var current_node : int = 0
var destination : Vector2
var current_destination : Vector2
var initial_position : Vector2
var at_dest : bool = true
var char_array : Array
var nav_ready : bool = false
var target = null

func _ready():
	var navs = get_tree().get_nodes_in_group("Nav")
	for n in navs:
		nav = n
	initial_position = position
	current_destination = main_destination
	team = false


func _process(delta):
	handle_rotation(delta)


func follow_path(delt):
	if path_array.size() == 0 or path_array.size() <= current_node:
		at_dest = true
		return
	var delta : Vector2 = path_array[current_node] - position
	if delta.length() < speed * delt:
		position = path_array[current_node]
		current_node += 1
		return
	delta /delta.length()
	movement_vector = delta.normalized()
	destination = path_array[current_node]
	

func set_path(dest :Vector2) :
	if not nav :
		print("error nov not set")
		return
	nav_ready = game_states.is_Astar_ready()
	if not nav_ready:
		return
	
	path_array = nav.get_simple_path(position,dest,false)
	current_node = 0
	at_dest = false
	
func _get_nearest_player() :
	var pls = get_tree().get_nodes_in_group("User")
	if pls.size() == 0:
		target = null
		return
	var min_distance : int = 99999
	for pl in pls:
		var dist = (position - pl.position).length()
		if dist < min_distance:
			min_distance = dist
			target = pl


#This Function Rotates Bot with a constatant Rotational speed
func handle_rotation(delta : float):
	var dest_angle : float = (destination - position).angle() + 1.57
	if abs(dest_angle - rotation) <= 0.1:
		return
		
	if dest_angle < 0 :
		dest_angle += 6.28
	if rotation < 0:
		rotation += 6.28
	if rotation > 6.28:
		rotation -= 6.28
		
	var aba : float = dest_angle - rotation
	if abs(aba) <= 6.28 - abs(aba) :
		rotation += sign(aba) * rotational_speed * delta
	else:
		rotation += -sign(aba) * rotational_speed * delta


#func _on_Monster_at_dest():
	#if is_in_combat:
	#	set_path(enemy_position)
	#else:
		#if main_destination.x == -1 and main_destination.y == -1:
		#	return
		#if position == main_destination:
		#	set_path(initial_position)
		#	return
		#set_path(main_destination)


func _on_Vision_body_entered(body):
	if body.is_in_group("Actor"):
		char_array.push_back(body)
		


func _on_Vision_body_exited(body):
	if body.is_in_group("Actor"):
		char_array.erase(body)