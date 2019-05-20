extends Particles2D

func _ready():
	get_tree().create_timer(lifetime).connect('timeout', self, 'stop_emitting')
	get_tree().create_timer(lifetime).connect('timeout', self, 'queue_free')

func stop_emitting():
	emitting = false

func SetColor(c):
	modulate = c