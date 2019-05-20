extends Label

func _ready():
	SignalSystem.connect("EnemyDied", self, "PointEarned")
	
func PointEarned():
	text = str(int(text)+1)