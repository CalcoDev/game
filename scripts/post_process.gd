extends Node

func _process(delta: float) -> void:
    Game.on_post_process.emit(delta)
