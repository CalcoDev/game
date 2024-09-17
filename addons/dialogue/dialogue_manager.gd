# TODO(calco): WHY DO WE EVEN NEED THIS LMAO
class_name DialogueManager
extends Node

@export_dir var speakers_dir: String = ""

static var speakers_init: bool = false
static var speakers_register: Dictionary = {}:
    get:
        assert(speakers_init, "ERROR: Tried accessing speakers register without it being initialised.")
        return speakers_register

# Stuff to do with displaying dialogue
var speed: float = 1.0

func _enter_tree() -> void:
    if not speakers_init:
        speakers_init = true
        var dir_q = []
        var dir_s = DirAccess.open(speakers_dir)
        dir_q.append([dir_s, speakers_dir])
        while len(dir_q) > 0:
            var dir = dir_q[0][0]
            var path = dir_q[0][1]
            dir_q.remove_at(0)
            dir.list_dir_begin()
            var file_path = dir.get_next()
            while file_path != "":
                var full_path = path + "/" + file_path
                if dir.current_is_dir():
                    dir_q.append([DirAccess.open(full_path), full_path])
                    file_path = dir.get_next()
                    continue
                var res = ResourceLoader.load(full_path)
                if res is Speaker:
                    speakers_register[res.id] = res
                file_path = dir.get_next()
