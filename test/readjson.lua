local json = require("libs/dkjson")

local file, err = io.open("memory.json", "r")
if not file then
    print("文件打开失败:", err)
    return
end

-- 读取全部内容到字符串
local content = file:read("*a")  -- "*a" 表示读取所有内容
file:close()  -- 关闭文件

local data, pos, err = json.decode(content, 1, nil)

print("memory.state:", data.memory.state)