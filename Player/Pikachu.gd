extends KinematicBody2D

var RANGE = 3.5
var SPEED = 100
var Player
var velocity := Vector2()

func _ready():
	$AnimatedSprite.play("Idle")
	
func _process(delta):
	var targetPos = Player.position - position
	var normalized = targetPos.normalized()
	
	velocity.x = (normalized * SPEED).x
	velocity.y = 100
	
	$AnimatedSprite.flip_h = velocity.x < 0
	
	var distanceX = abs(to_global(targetPos).x - position.x)
	
	if distanceX < RANGE:
		$AnimatedSprite.play("Idle")
		velocity = move_and_slide(Vector2(0, 100), Vector2(0, -1))
	else:
		$AnimatedSprite.play("Run")
		velocity = move_and_slide(velocity, Vector2(0, -1))
		
	if Player.on_ground:
		var tileMap = get_tree().get_root().get_node("World").get_node("TileMap")
		
		var p = Player.get_node("Position2D").global_position
		var myPos = $Position2D.global_position
		
		var playerTilePos = tileMap.world_to_map(p)
		var myTilePos = tileMap.world_to_map(myPos)
		
		if playerTilePos.y < myTilePos.y:
			global_position = p
			global_position.y -= 20