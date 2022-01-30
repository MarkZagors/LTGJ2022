extends Node2D

var time : float = 0.0
var playStarted = false
var bpm = 120

var hp = 100

onready var notePreload = preload("res://Note.tscn")
onready var hitParticles = preload("res://HitParticles.tscn")
onready var points = get_node("Points")
onready var hpBar = get_node("HPBar")

onready var data = {
	"Rythm1": {
		"bpm": 120,
		"song": preload("res://Music/gamejamjam1.wav"),
		"notes": "0r 400r 800r 1200r 1400r 1500r 1600l 2000r 2400d 2800d 3000d 3100l 3200u 3400r 3600d 3800l 4000d 4200l 4400u 4600d 4700r 4800l 5000u 5200r 5400d 5600l 5800d 6000l 6200u 6300l 6400d 6600u 6800r 7000d 7200l 7400d 7600l 7800d 7900r 8000u 8200r 8400l 8600d 8800r 9000d 9200r 9400d 9500l 9600u 10000d 10400l 10800d 11000r 11100u 11200r 11600l 12000d 12400d 13500w",
	},
	"Rythm2": {
		"bpm": 120,
		"song": preload("res://Music/gamejamjam1.wav"),
		"notes": "",
	},
	"Rythm3": {
		"bpm": 120,
		"song": preload("res://Music/section1.wav"),
		"notes": "200l 600l 1000l 1400l 1800r 2200r 2600r 3400r 3700d 3800r 4200l 4500d 4600l 5000u 5300r 5400u 5800u 6100l 6200u 6600d 6900d 7000r 7400u 7700u 7800l 8200l 8500l 8600u 9000r 9300r 9400d 10400w",
	},
}

var notesStr = "0r 400r 800r 1200r 1600r 500l 1600w"
var notes = []

func _ready():
	bpm = data[Autoload.rythmOrbID].bpm
	notesStr = data[Autoload.rythmOrbID].notes
	get_node("Music").stream = data[Autoload.rythmOrbID].song
	
	updateHp()
	print(Autoload.currentRythmID)
	get_tree().paused = false
	time = (bpm/60.0) * -3.0
	var regex = RegEx.new()
	regex.compile("(?<digit>[0-9]+)(?<dir>[a-z])")
	for note in notesStr.split(" "):
		var result = regex.search(note)
		notes.append([float(int(result.get_string("digit")))/100.0 + time, result.get_string("dir")])
	if notes[0][0] == (bpm/60.0) * -3.0:
		create_right()
		notes.remove(0)
	
func _process(delta):
	time += delta * (bpm/60.0)
	if time > 0.0 and playStarted == false:
		get_node("Music").play()
		playStarted = true
	if len(notes) > 0:
		if notes[0][0] == stepify(time,0.25):
			match notes[0][1]:
				'r':
					create_right()
				'l':
					create_left()
				'u':
					create_up()
				'd':
					create_down()
				'w':
					win()
			notes.remove(0)
	
	if Input.is_action_just_pressed("up"):
		checkPress('u')
	if Input.is_action_just_pressed("down"):
		checkPress('d')
	if Input.is_action_just_pressed("right"):
		checkPress('r')
	if Input.is_action_just_pressed("left"):
		checkPress('l')

func checkPress(noteDir):
	for note in get_node("Points").get_children():
		if note.direction == noteDir:
			if note.position.length() < 100.0:
				var part = hitParticles.instance()
				part.emitting = true
				get_node("Particles").add_child(part)
				note.queue_free()
			elif note.position.length() < 200:
				hp -= 10
				updateHp()
				note.queue_free()
			break

func updateHp():
	hpBar.value = hp
	if hp < 1:
		showLoseScreen()

func showLoseScreen():
	get_node("LoseScreen").visible = true
	get_tree().paused = true

func showWinScreen():
	get_node("WinScreen").visible = true

func create_right():
	var note = notePreload.instance()
	note.direction = 'r'
	note.vel = Vector2(-1,0)
	note.position = Vector2(1050,0)
	note.rotation_degrees = 90
	points.add_child(note)

func create_left():
	var note = notePreload.instance()
	note.direction = 'l'
	note.vel = Vector2(1,0)
	note.position = Vector2(-1050,0)
	note.rotation_degrees = 270
	points.add_child(note)

func create_up():
	var note = notePreload.instance()
	note.direction = 'u'
	note.vel = Vector2(0,1)
	note.position = Vector2(0,-1050)
	note.rotation_degrees = 0
	points.add_child(note)

func create_down():
	var note = notePreload.instance()
	note.direction = 'd'
	note.vel = Vector2(0,-1)
	note.position = Vector2(0,1050)
	note.rotation_degrees = 180
	points.add_child(note)


func _on_TryAgainButton_pressed():
	var _err = get_tree().reload_current_scene()

func _on_QuitButton_pressed():
	var _err = get_tree().change_scene("res://Main.tscn")

func win():
	Autoload.wonLevels.append(Autoload.rythmOrbID)
	get_node("WinTimeout").play("Fade")

func changeScene():
	var _err = get_tree().change_scene("res://Main.tscn")
