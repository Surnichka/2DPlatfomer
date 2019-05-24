extends Node2D

export (int)var spawnTime 

const ENEMY = preload("res://Enemy/SlimeEnemy.tscn")
var PRESET_STATS =[
	{health = 200, damage = 5, regen = 1, color=Color(255, 0, 0)},
	{health = 100, damage = 10, regen = 2, color=Color(255, 255, 0)},
	{health = 50, damage = 15, regen = 3, color=Color(255, 255, 255)}]
	
var currentStats := {}

func _ready():
	randomize()
	CreateEnemy()

func on_die_signal():
	$SpawnTimer.wait_time = spawnTime
	$SpawnTimer.start()

func _on_SpawnTimer_timeout():
	CreateEnemy()

func CreateEnemy():
	var enemy = ENEMY.instance()
	add_child(enemy)
	
	if currentStats.empty():
		var idx = randi() % PRESET_STATS.size()
		currentStats = PRESET_STATS[idx]
		currentStats.level = 1
	else:
		currentStats.health += randi() % 10
		currentStats.damage += randi() % 10
		currentStats.regen += randi() % 10
		currentStats.level += 1
		
	enemy.SetLevel(currentStats.level)
	enemy.SetHealth(currentStats.health)
	enemy.SetDamage(currentStats.damage)
	enemy.SetRegen(currentStats.regen)
	enemy.set_global_position(global_position)
	enemy.Health.connect("died", self, "on_die_signal")