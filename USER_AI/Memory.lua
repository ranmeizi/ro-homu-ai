local json = require('AI_sakray.USER_AI.libs.dkjson')

local filePath = 'AI_sakray/memory.json'

Memory = {}

-- 合并函数：将新表的键值对复制到原表，但不覆盖已存在的键
local function mergePreserveOriginal(dest, src)
    for k, v in pairs(src) do
        if dest[k] == nil then -- 仅当原表没有该键时才添加
            dest[k] = v
        end
    end
    return dest -- 仍然返回原表的引用
end



--- 脚本执行一开始 读取 memory
function Memory.load()
    local file, err = io.open(filePath, "r")
    if not file then
        print("文件打开失败:", err)
        return
    end

    -- 读取全部内容到字符串
    local content = file:read("*a") -- "*a" 表示读取所有内容
    file:close()                    -- 关闭文件

    local data, pos, err = json.decode(content, 1, nil)

    -- 使用合并函数
    mergePreserveOriginal(Memory, data)
end

--- 脚本结束 存储 memory
function Memory.store()
    local options = {
        indent = true,    -- 美化输出，带缩进和换行
        level = 0,        -- 初始缩进级别
        noprotect = false -- 不保护循环引用
    }

    Memory.load = nil
    Memory.store = nil

    TraceAI('Store memory:'..Memory.tick)

    local jsonString = json.encode(Memory, options)

    local file, err = io.open(filePath, "w") -- "w" 模式表示写入，会覆盖文件内容

    if not file then
        TraceAI('无法打开文件')
        error("无法打开文件: " .. err)
    end

    -- 将内容写入文件
    ---@diagnostic disable-next-line: param-type-mismatch
    file:write(jsonString)

    -- 关闭文件
    file:close()
end
