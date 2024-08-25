class_name Coro
extends Resource

@export var finished: bool = false
@export var stopped: bool = false

signal on_finished()
signal on_stopped()

var stoppable: bool = true
var awaitable

var should_cont:
    get:
        return not (finished or stopped)

func _init(p_awaitable, p_stoppable) -> void:
    finished = false
    stopped = false
    awaitable = p_awaitable
    stoppable = p_stoppable

func run(params: Dictionary) -> bool:
    if awaitable is Coro:
        await awaitable.run()
    elif awaitable is Callable:
        await awaitable.call(self, params)
    else:
        await awaitable
    if stoppable and stopped:
        finished = false
        return false
    finished = true
    on_finished.emit()
    return true

func stop():
    if not stoppable:
        return
    stopped = true
    on_stopped.emit()

static func start_coroutine(runnable) -> Coro:
    var coro = Coro.new(runnable, true)
    return coro

static func first_of(awaitables: Array, stop_on_end=true):
    var coros: Array[Coro] = []
    var coro_finished = [- 1]
    
    var on_coro_finished = func(idx):
        coro_finished[0] = idx
    
    for c_awaitable in awaitables:
        var idx = len(coros)
        coros.append(Coro.new(c_awaitable, true))
        coros[idx].on_finished.connect(func(): on_coro_finished.call(idx))
    
    for coro in coros:
        coro.run({})
    
    while coro_finished[0] == - 1:
        await Game.on_pre_process
    if stop_on_end:
        for coro in coros:
            coro.stop()

    return awaitables[coro_finished[0]]
