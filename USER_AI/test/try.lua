require 'AI_sakray.USER_AI.Const'
require 'AI_sakray.USER_AI.Util'
require 'AI_sakray.USER_AI.Memory'

Memory.load()

local function loop(id)
    print("memory:", Memory.tick,Memory.memory.state)
    
    Memory.tick = Memory.tick + 1

    if math.random() > 0.5 then
        error('给我死')
    end

    Memory.store()
end

function AI(id)
    xpcall(function()
        loop(id)
    end, function(err)
        print("捕获到错误:", debug.traceback(err, 2))
        Memory.store()
    end)
end

AI()