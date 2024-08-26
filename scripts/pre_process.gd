extends Node

func _process(delta: float) -> void:
    Game.on_pre_process.emit(delta)
