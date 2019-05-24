extends KinematicBody2D

var STOPING_RANGE = 4
var FOLLOWING_RANGE = 5
var SPEED = 120
var Player
var velocity := Vector2()

const TELEPORT_ANIM = preload("res://Player/HitSkill/hit_animation.tscn")

func _ready():
	$AnimatedSprite.play("Idle")
	
func _process(delta):
	var targetPos = Player.position - position
	var normalized = targetPos.normalized()
	
	velocity.x = (normalized * SPEED).x
	velocity.y = 150
	
	$AnimatedSprite.flip_h = velocity.x < 0
	
	var distanceX = abs(to_global(targetPos).x - position.x)
	
	if $AnimatedSprite.is_playing() and $AnimatedSprite.animation == "Attack1":
		pass
	else:
		if distanceX < STOPING_RANGE:
			$AnimatedSprite.play("Idle")
		elif $AnimatedSprite.animation == "Idle" and distanceX > FOLLOWING_RANGE:
			$AnimatedSprite.play("Run")
			
	if $AnimatedSprite.animation == "Run":
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		velocity = move_and_slide(Vector2(0, 100), Vector2(0, -1))
		
	if Player.on_ground:
		var tileMap = get_tree().get_root().get_node("World").get_node("TileMap")
		
		var p = Player.get_node("Position2D").global_position
		var myPos = $Position2D.global_position
		
		var playerTilePos = tileMap.world_to_map(p)
		var myTilePos = tileMap.world_to_map(myPos)
		
		if playerTilePos.y < myTilePos.y:
			$AnimatedSprite.play("Attack1")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "Attack1":
		var teleport_anim = TELEPORT_ANIM.instance()
		add_child(teleport_anim)
		
		var p = Player.get_node("Position2D").global_position
		global_position = p
		global_position.y -= 20
		global_position.x -= 20
		teleport_anim.Show(global_position, false)
		$AnimatedSprite.play("Idle")
