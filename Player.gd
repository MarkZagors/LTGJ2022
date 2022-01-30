extends KinematicBody2D

var speed : int = 500
var jumpForce : int = 1000
var gravity : int = 1800
var vel : Vector2 = Vector2()
var kickback = 800
var kickback_drag = 2000

var kickback_vel = 0
onready var sprite = get_node("Sprite")
var colliding_right = false
var colliding_left = false
var canMove = true

func _ready():
	get_tree().paused = false
	for level in Autoload.wonLevels:
		get_node("..").find_node(level).get_node("CollisionShape2D").disabled = true
		get_node("..").find_node(level).get_node("Sprite").visible = false
	if Autoload.charPos != Vector2(0,0) and not Autoload.quited:
		canMove = false
		get_node("..").find_node(Autoload.rythmOrbID).get_node("CollisionShape2D").disabled = true
		get_node("..").find_node(Autoload.rythmOrbID).get_node("Sprite").visible = true
		get_node("Unpause").start()
		get_node("ExplodeTimer").start()
		get_node("Sprite").animation = "idle"
		position = Autoload.charPos

func _physics_process (delta):
	if canMove == false:
		return
	
	var bodies = get_node("PlatformArea").get_overlapping_bodies()
	
	if vel.y < 0:
		collision_layer = 1
	elif bodies != [] and bodies[0].name == "TilemapPlatform":
		collision_layer = 1
	else:
		collision_layer = 3
	
	if kickback_vel > 50:
		kickback_vel -= delta * kickback_drag
	elif kickback_vel < -50:
		kickback_vel += delta * kickback_drag
	else:
		kickback_vel = 0
	vel.x = kickback_vel
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	elif Input.is_action_pressed("move_right"):
		vel.x += speed
	
	if Input.is_action_pressed("move_left") and is_on_floor():
		get_node("Sprite").animation = "run"
	elif Input.is_action_pressed("move_right") and is_on_floor():
		get_node("Sprite").animation = "run"
	elif is_on_wall():
		get_node("Sprite").animation = "wall"
	elif not is_on_floor() and vel.y > 0:
		get_node("Sprite").animation = "jumpDown"
	elif not is_on_floor() and vel.y <= 0:
		get_node("Sprite").animation = "jumpUp"
	else:
		get_node("Sprite").animation = "idle"
	
	vel.y += gravity * delta
	if is_on_wall():
		vel.y = min(vel.y,150)
	colliding_left = false
	colliding_right = false
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y -= jumpForce
	else:
		if get_node("WallLeft").is_colliding():
			colliding_left = true
		if get_node("WallRight").is_colliding():
			colliding_right = true
	
	if Input.is_action_just_pressed("jump") and colliding_right:
		vel.y = 0
		vel.y -= jumpForce
		kickback_vel = -kickback
	if Input.is_action_just_pressed("jump") and colliding_left:
		vel.y = 0
		vel.y -= jumpForce
		kickback_vel = kickback
	
	if Input.is_action_just_released("jump") and vel.y < 0:
		vel.y = 0
	
	if vel.x < 0:
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.flip_h = false
	
	vel = move_and_slide(vel, Vector2.UP)

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		for area in get_node("PlatformArea").get_overlapping_areas():
			if area.is_in_group("zoneButton"):
				Autoload.currentRythmID = area.id
				Autoload.charPos = position
				Autoload.rythmOrbID = area.name
				get_node("Fade/AnimationPlayer").play("Fade")
				get_node("../Music/AnimationPlayer").play("Fade")

func changeToRythm():
	var _err = get_tree().change_scene("res://RythmSection.tscn")

func _on_PlatformArea_area_shape_entered(area_id, area, area_shape, local_shape):
	if area.is_in_group("zoneButton"):
		get_node("EnterLabel").visible = true

func _on_PlatformArea_area_shape_exited(area_id, area, area_shape, local_shape):
	if area.is_in_group("zoneButton"):
		get_node("EnterLabel").visible = false


func _on_Unpause_timeout():
	canMove = true


func _on_ExplodeTimer_timeout():
	var node = get_node("..").find_node(Autoload.rythmOrbID)
	node.get_node("Sprite").visible = false
	node.get_node("DeathParticles").emitting = true
