extends StaticBody2D

onready var coin_scene = load("res://Scenes/Coin.tscn")
onready var mushroom_scene = load("res://Scenes/Mushroom.tscn")

export var hit_times = 1

enum BonusType{
	COIN, # 0 = Coin
	MUSHROOM # 1 = Mushroom
}

export var bonus_type = BonusType.COIN

func spawn_coins():
	var new_coin = coin_scene.instance()
	add_child(new_coin)
	get_parent().get_parent().points += 100

func spawn_mushroom():
	var new_mushroom = mushroom_scene.instance()
	call_deferred("add_child", new_mushroom)

func _ready():
	$AnimationPlayer.play("default")
	


func _on_HitBox_body_entered(body):
	if body.is_in_group("player") && hit_times > 0:
		
		match bonus_type:
			BonusType.COIN:
				spawn_coins()
			BonusType.MUSHROOM:
				spawn_mushroom()
				
		hit_times -= 1
		$AnimationPlayer.play("hitbox")
		



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hitbox" && hit_times > 0:
		$AnimationPlayer.play("default")
