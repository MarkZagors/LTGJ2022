extends Sprite

var direction = 'r'
var vel : Vector2
var speed = 350
var past = false

func _process(delta):
	position += vel * delta * speed
	if position.length() < 50.0:
		past = true
	if past and position.length() > 100.0:
		get_node("../..").hp -= 30
		get_node("../..").updateHp()
		queue_free()
