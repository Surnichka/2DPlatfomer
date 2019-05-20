extends Node2D

signal died

onready var HealthProgress := $TextureProgress
	
func TakeDamage(damage):
	HealthProgress.value -= damage
	if HealthProgress.value <= 0:
		HealthProgress.value = 0
		emit_signal("died")
		
func SetHealth(health:float):
	$TextureProgress.max_value = health
	$TextureProgress.value = health
	
func AddHealth(health):
	HealthProgress.value += health