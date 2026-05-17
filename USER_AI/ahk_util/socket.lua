--[[
    连接 tcp_ctrl.ahk
    优先 luasocket TCP；若无则写入 AI_sakray/AHK_scripts/tcp_cmd.txt（AHK 轮询）
]]

local M = {
    host = "127.0.0.1",
    port = 19789,
    timeout = 2,
    transport = "auto",  -- auto | tcp | file
    cmd_file = "AI_sakray/AHK_scripts/tcp_cmd.txt",
    debug = true,
}

local _luasocket = nil
local _luasocket_checked = false

TraceAI("[ahk_util.socket] 模块已加载")

local function log(msg)
    TraceAI("[ahk_util.socket] " .. msg)
end

local function check_luasocket()
    if _luasocket_checked then
        return _luasocket
    end
    _luasocket_checked = true
    local ok, lib = pcall(require, "socket")
    if not ok then
        ok, lib = pcall(require, "socket.core")
    end
    if ok then
        _luasocket = lib
        log("luasocket 可用")
    else
        _luasocket = nil
        log("luasocket 不可用: " .. tostring(lib) .. " → 将使用文件通道")
    end
    return _luasocket
end

local function build_line(cmd, ...)
    local line = tostring(cmd)
    for i = 1, select("#", ...) do
        line = line .. " " .. tostring(select(i, ...))
    end
    return line .. "\n"
end

---诊断信息（TraceAI 输出）
---@return table
function M.diagnose()
    local lib = check_luasocket()
    local info = {
        transport = M.transport,
        luasocket = lib ~= nil,
        host = M.host,
        port = M.port,
        cmd_file = M.cmd_file,
    }
    if _G.json then
        log("diagnose " .. json.encode(info))
    else
        log("diagnose luasocket=" .. tostring(info.luasocket) .. " file=" .. info.cmd_file)
    end
    return info
end

local function send_tcp(line)
    local socket = check_luasocket()
    if not socket then
        return false, "no_luasocket"
    end

    local tcp, connErr = socket.connect(M.host, M.port)
    if not tcp then
        return false, "connect_fail: " .. tostring(connErr)
    end

    tcp:settimeout(M.timeout)
    local sent, sendErr = tcp:send(line)
    if not sent then
        tcp:close()
        return false, "send_fail: " .. tostring(sendErr)
    end

    local resp, recvErr = tcp:receive("*l")
    tcp:close()

    if not resp then
        return false, "recv_fail: " .. tostring(recvErr)
    end

    local okResp = resp:sub(1, 3) == "OK"
    log("TCP → " .. line:gsub("\n$", "") .. " | " .. resp)
    return okResp, resp
end

local function send_file(line)
    local f, err = io.open(M.cmd_file, "a")
    if not f then
        return false, "file_open_fail: " .. tostring(err)
    end
    f:write(line)
    f:close()
    log("FILE → " .. M.cmd_file .. " | " .. line:gsub("\n$", ""))
    return true, "OK file"
end

---发送一条指令
---@param cmd string|number
---@param ... string|number
---@return boolean ok
---@return string response
function M.send(cmd, ...)
    local line = build_line(cmd, ...)

    if M.transport == "file" then
        return send_file(line)
    end

    if M.transport == "tcp" then
        return send_tcp(line)
    end

    -- auto: 先 TCP，失败再文件
    local ok, resp = send_tcp(line)
    if ok then
        return true, resp
    end
    log("TCP 失败(" .. tostring(resp) .. ")，尝试文件通道")
    return send_file(line)
end

function M.plant_anemone()
    return M.send(1)
end

return M
