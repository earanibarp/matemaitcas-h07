extends Node2D

var level = 0
var time_left = 0
var score = 0

export (PackedScene) var Gem

func _ready():
	randomize()
	spawn_gems()
	time_left = 15
	$HUD.update_timer(time_left)
	$HUD/LabelGameOver.visible = false

func spawn_gems():
	if Gem != null:
		for index in range(5 + level):
			var Gema = Gem.instance()
			Gema.position = Vector2(rand_range(0, 480), rand_range(0, 720))
			$GemContainer.add_child(Gema)
	
	
func _process(delta):
	update_platform_position()

	if $GemContainer.get_child_count() == 0:
		level += 1
		spawn_gems()
		time_left += 5

func update_platform_position(): # función para que la plataforma siga al enemigo
	$Platform.position.x = $Enemy.position.x

func _on_GameTimer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()


func _on_Player_picked():
	score += 1
	$HUD.update_score(score)
	
func game_over():
	$GameTimer.stop()
	$HUD/LabelGameOver.visible = true
	$Player.game_over()
	yield(get_tree().create_timer(1.5), "timeout") # Crea temporizador de 1.5 seg
	get_tree().change_scene("res://menu/Menu.tscn") # Vuelve a la escena principal


func _on_Player_hurt():
	game_over()
	
