class_name Coro
extends Resource

@export var finished: bool = false
@export var stopped: bool = false

static var YES_CTX: bool = true
static var NO_CTX: bool  = false

signal on_finished()
signal on_stopped()

var stoppable: bool = true
var awaitable: Awaitable

var should_cont:
    get:
        return not (finished or stopped)

func _init(p_awaitable, p_stoppable) -> void:
    finished = false
    stopped = false
    if p_awaitable is Awaitable:
        awaitable = p_awaitable
    else:
        awaitable = Awaitable.try_from(p_awaitable)
    stoppable = p_stoppable

func run() -> bool:
    await awaitable.run(self)
    if stoppable and stopped:
        finished = false
        return false
    finished = true
    on_finished.emit()
    return true

func run_params(params) -> bool:
    await awaitable.run_params(self, params)
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

# Returns the first awaitable that finished
# TODO(calco): Should this listen for on_stopped too?
static func first_of(awaitables: Array, listen_on_stopped: bool, stop_on_end=true) -> Awaitable:
    var coros: Array = []
    var coro_finished = [- 1]
    
    var on_coro_finished = func(idx, p_stopped):
        if not p_stopped or (p_stopped and listen_on_stopped):
            coro_finished[0] = idx
    
    for i in len(awaitables):
        awaitables[i] = Awaitable.try_from(awaitables[i])
        var idx = len(coros)
        coros.append(Coro.new(awaitables[i], true))
        coros[idx].on_finished.connect(func(): on_coro_finished.call(idx, false))
        coros[idx].on_stopped.connect(func(): on_coro_finished.call(idx, true))
    
    for coro in coros:
        coro.run()
    
    while coro_finished[0] == - 1:
        await Game.on_pre_process
    if stop_on_end:
        for coro in coros:
            coro.stop()

    return awaitables[coro_finished[0]]
