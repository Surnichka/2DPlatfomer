extends Label

func _ready():
	$Timer.connect("timeout", self, "OnTimerEnd")
	
func Show(damage):
	$Timer.start()
	set_text(str(damage))
	rect_position.y -= 25
	rect_position.x -= 2
	
func _process(delta):
	self.rect_position.y -= 0.35
	
func OnTimerEnd():
	queue_free()
	