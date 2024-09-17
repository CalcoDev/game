class_name Player
extends CharacterBody2D

@export_group("Movement")
@export var WallSlideAngle: float = 30
@export var MovementSpeed: float = 100

var _move = Vector2.ZERO

# func _enter_tree():
# 	Game.ActivePlayer = self
#
# func _exit_tree():
# 	Game.ActivePlayer = null

func _process(delta):
	_move.x = Input.get_axis("LEFT", "RIGHT")
	_move.y = Input.get_axis("UP", "DOWN")
	_move = _move.normalized()

	_move = _move * MovementSpeed * delta
	MoveAndCollide(Vector2.RIGHT * _move.x)
	MoveAndCollide(Vector2.DOWN * _move.y)

var _d = Vector2.ZERO
var _d1 = Vector2.ZERO
func MoveAndCollide(motion: Vector2):
	var col = move_and_collide(Vector2.RIGHT * motion.x)
	if col != null:
		var norm = col.get_normal()
		var dir = get_perpendicular(norm)
		var ang = norm.angle_to(motion)
		if ang > 0:
			dir.x *= - 1
			dir.y *= - 1
		if PI - abs(ang) > deg_to_rad(WallSlideAngle):
			move_and_collide(dir * col.get_remainder().length())
	col = move_and_collide(Vector2.DOWN * motion.y)
	if col != null:
		var norm = col.get_normal()
		var dir = get_perpendicular(norm)
		var ang = norm.angle_to(motion)
		if ang > 0:
			dir.x *= - 1
			dir.y *= - 1
		if PI - abs(ang) > deg_to_rad(WallSlideAngle):
			move_and_collide(dir * col.get_remainder().length())
 
func v2_v3(vec):
	return Vector2(vec.x, vec.z)

func v3_v2(vec):
	return Vector3(vec.x, 0, vec.y)

func get_perpendicular(vec):
	return v2_v3(Vector3.UP.cross(v3_v2(vec)))

func _draw():
	draw_line(Vector2.ZERO, _d * 100, Color.DARK_BLUE, 2)
	draw_line(Vector2.ZERO, _d1 * 100, Color.DARK_RED, 2)
	pass
