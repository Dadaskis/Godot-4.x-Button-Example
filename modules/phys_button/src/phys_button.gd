extends StaticBody3D
class_name PhysButton

signal on_use()

func use():
	print("ON USE")
	emit_signal("on_use")
