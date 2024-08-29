class_name DialogueManager
extends Node

@export_dir var speakers_dir: String = "";
@export_file("*.txt") var _dbg_dialogue: String = "";

# TODO(calco): Dialopgue Display should be its own component probs
@export var dialogue_box: NinePatchRect = null
@export var dialogue_box_marker: TextureRect = null
@export var dialogue_box_lbl: RichTextLabel = null

static var speakers_init: bool = false
static var speakers_register: Dictionary = {}:
    get:
        assert(speakers_init, "ERROR: Tried accessing speakers register without it being initialised.")
        return speakers_register

func _enter_tree() -> void:if not speakers_init:
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
                speakers_register[res.name] = res
            file_path = dir.get_next()

func _ready() -> void:
    # var d = Dialogue.from_file(_dbg_dialogue)
    # play_dialogue(d)


    # var test = (func():
    #     print("asdasd")).bind(Coroutine.BIND_CTX)
    # print(test.get_bound_arguments())

    # var test = [false, false, false]
    # var a = func(idx: int):
    #     test[idx] = true
    # for i in 3:
    #     var b = func():
    #         a.call(i)
    #     b.call()
    # print(test)
    pass

func play_dialogue(dialogue: Dialogue) -> void:
    dialogue.restart_tokenizer()

    dialogue_box_lbl.text = dialogue.get_string_till_nextpage()
    dialogue_box_lbl.visible_characters = 0

    var token: Dialogue.Token
    var wait_frame = true
    var skipped_prev_string = false
    while true:
        if wait_frame:
            await Game.on_pre_process
            # TODO(calco): Check if should stop
        token = dialogue.get_next_token()
        wait_frame = false
        match token.type:
            # TODO(calco): Work on this later
            Dialogue.Token.SPEAKER:
                # current_speaker = token.value
                pass
            Dialogue.Token.SPEED:
                # speed = token.value
                pass
            Dialogue.Token.WAIT:
                await get_tree().create_timer(token.value).timeout
                # TODO(calco): Check if should stop
                # if not coro.should_cont:
                #     return
            Dialogue.Token.NEWPAGE:
                await await_player_input("DIALOGUE_NEXT")
                dialogue_box_lbl.text = dialogue.get_string_till_nextpage()
                dialogue_box_lbl.visible_characters = 0
                wait_frame = true
                skipped_prev_string = false
            Dialogue.Token.STRING:
                if skipped_prev_string:
                    dialogue_box_lbl.visible_characters += len(token.value)
                    continue

                # var c1 = func():
                #     await await_player_input("DIA_NEXT")

                # var ret = await Coro.first_of([play_dialogue_page_coro, [await_player_input, "DIALOGUE_SKIP", Coro.NO_CTX]], false, true)
                # text_display.visible_characters = len(text_display.text)
                # if ret.to_await == play_dialogue_page_coro:
                #     wait_frame = true
                # else:
                #     skipped_prev_string = true
                pass
            Dialogue.Token.NEWLINE:
                # text_display.visible_characters += 1
                pass
            Dialogue.Token.EOF:
                # await await_player_input("DIALOGUE_NEXT")
                break
            Dialogue.Token.UNKNOWN:
                push_warning("WARNING: Dialogue Manager encountered a token it didn't know how to handle! Skipping over it ...")

func await_player_input(action: String) -> void:
    while true:
        await Game.on_pre_process
        if Input.is_action_just_pressed(action):
            break









