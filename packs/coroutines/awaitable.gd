class_name Awaitable

var to_await
var last_used_coro: Coro = null

func run(coro: Coro):
    last_used_coro = coro

func run_params(coro: Coro, _p_params):
    last_used_coro = coro

static func try_from(arg) -> Awaitable:
    if arg is Signal:
        return SignalA.new(arg)
    if arg is Coro:
        return CoroA.new(arg)
    if arg is Callable:
        return CallableA.new(arg)
    if arg is Array:
        if len(arg) == 3:
            var function = arg[0]
            var args = arg[1]
            var pass_ctx = arg[2]
            assert(function is Callable and pass_ctx is bool, "ERROR: Invalid awaitable.")
            return CallableParamsA.new(function, args, pass_ctx)
    assert(false, "ERROR: Could not parse awaitable.")
    return null

class SignalA extends Awaitable:
    func _init(p_signal: Signal) -> void:
        to_await = p_signal
    
    func run(p_coro: Coro):
        super(p_coro)
        await to_await
    
    func run_params(_p_coro: Coro, _p_params):
        assert(false, "ERROR: Cannot pass parameters to a signal!")

class CoroA extends Awaitable:
    func _init(p_coro: Coro) -> void:
        to_await = p_coro
    
    func run(p_coro: Coro):
        super(p_coro)
        await to_await.run()
    
    func run_params(p_coro: Coro, p_params):
        super(p_coro, p_params)
        await to_await.run(p_params)

class CallableA extends Awaitable:
    func _init(p_callable: Callable) -> void:
        to_await = p_callable
    
    func run(p_coro: Coro):
        super(p_coro)
        match to_await.get_argument_count():
            0:
                await to_await.call()
            1:
                await to_await.call(p_coro)
    
    func run_params(p_coro: Coro, p_params):
        super(p_coro, p_params)
        match to_await.get_argument_count():
            1:
                await to_await.call(p_params)
            2:
                await to_await.call(p_coro, p_params)

# asdasdasd
# asdasda

class CallableParamsA extends Awaitable:
    var params
    var pass_ctx: bool

    func _init(p_callable: Callable, p_params, p_pass_ctx: bool) -> void:
        to_await = p_callable
        params = p_params
        pass_ctx = p_pass_ctx

    func run(p_coro: Coro):
        super(p_coro)
        if pass_ctx:
            await to_await.call(p_coro, params)
        else:
            await to_await.call(params)
    
    func run_params(p_coro: Coro, p_params):
        super(p_coro, p_params)
        if pass_ctx:
            await to_await.call(p_coro, params, p_params)
        else:
            await to_await.call(params, p_params)
