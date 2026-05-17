#Requires AutoHotkey v2.0+
; 用法: tcp_ctrl.ahk [端口]   默认 127.0.0.1:19789
; 协议: 每行一条指令，空格分隔参数，\n 结尾 → OK / ERR
; TCP 依赖 lib\Socket.ahk (thqby/ahk2_lib)

#Include lib\Socket.ahk

#SingleInstance Force
CoordMode("Mouse", "Screen")

Log(msg) {
    try FileAppend(Format("{}`t{}\n", A_Now, msg), A_ScriptDir "\tcp_ctrl.log", "UTF-8")
}

Log("=== tcp_ctrl 启动 ===")

global TCP_PORT := 19789
global TCP_HOST := "127.0.0.1"
global ListenSocket
global Clients := Map()

if (A_Args.Length >= 1 && IsInteger(A_Args[1]))
    TCP_PORT := Integer(A_Args[1])

try {
    StartTcpServer()
    Log("监听成功 " TCP_HOST ":" TCP_PORT)
} catch as e {
    Log("启动失败: " e.Message)
    MsgBox("无法监听 " TCP_HOST ":" TCP_PORT "`n" e.Message "`n`n详见: " A_ScriptDir "\tcp_ctrl.log", "tcp_ctrl", 16)
    ExitApp(1)
}

SetupTray() {
    global TCP_PORT, TCP_HOST
    TraySetIcon(A_AhkPath, 1)   ; 使用 AutoHotkey 自带绿色 H 图标
    A_IconTip := Format("tcp_ctrl`n{}:{}", TCP_HOST, TCP_PORT)
    A_TrayMenu.Delete()
    A_TrayMenu.Add("退出", (*) => ExitApp())
    A_TrayMenu.Add("打开日志", (*) => Run(A_ScriptDir "\tcp_ctrl.log"))
    A_TrayMenu.Default := "退出"
}

SetupTray()
Log("托盘已就绪")
SetTimer(PollCmdFile, 200)
OnExit(Shutdown)
Persistent()   ; 保持进程与托盘，防止自动退出

global CMD_FILE := A_ScriptDir "\tcp_cmd.txt"

; ── 底层控制函数（不暴露 TCP，handler 里组合调用）──

global _BuiltinSend := Send

GetScreenCenter() {
    return { x: A_ScreenWidth // 2, y: A_ScreenHeight // 2 }
}

MoveTo(x, y) {
    MouseMove(x, y, 0)
}

MouseClick(btn := "L", count := 1) {
    static downUp := Map(
        "Left",   [0x0002, 0x0004],
        "Right",  [0x0008, 0x0010],
        "Middle", [0x0020, 0x0040],
    )
    which := BtnToWhich(btn)
    pair := downUp.Has(which) ? downUp[which] : downUp["Left"]
    loop Max(1, count) {
        DllCall("mouse_event", "UInt", pair[1], "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        Sleep(40)
        DllCall("mouse_event", "UInt", pair[2], "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
    }
}

KeyPress(keys, count := 1) {
    loop Max(1, count)
        _BuiltinSend(keys)
}

BtnToWhich(btn) {
    switch StrUpper(btn) {
        case "L", "LEFT":   return "Left"
        case "R", "RIGHT":  return "Right"
        case "M", "MIDDLE": return "Middle"
        default:            return "Left"
    }
}

; ── 10 条 TCP 自定义指令 handler ──

InitTcpHandlers() {
    static table := 0
    if (table)
        return table
    table := Map(
        "1",  TCP_Cmd01, "2",  TCP_Cmd02, "3",  TCP_Cmd03,
        "4",  TCP_Cmd04, "5",  TCP_Cmd05, "6",  TCP_Cmd06,
        "7",  TCP_Cmd07, "8",  TCP_Cmd08, "9",  TCP_Cmd09,
        "10", TCP_Cmd10,
        ; TODO: 在此注册指令别名，如 "MY_CMD", TCP_Cmd01
    )
    return table
}

/**
 * 炼金种海葵
 * @param parts 
 * @returns {String} 
 */
TCP_Cmd01(parts) {
    Log("炼金种海葵")
    ; 移动到屏幕中央
    center := GetScreenCenter()
    MoveTo(center.x, center.y)
    ; 点击 L 键
    KeyPress("L")
    Sleep(1000)
    ; 随机移动
    MoveTo(Random(center.x - 60, center.x + 60), Random(center.y - 60, center.y + 60))
    Sleep(50)
    ; 点击左键（MoveTo 已定位，mouse_event 比 Click() 更易被游戏识别）
    MouseClick("L")
    return "OK"
}

TCP_Cmd02(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd03(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd04(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd05(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd06(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd07(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd08(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd09(parts) {
    ; TODO
    return "ERR TODO"
}

TCP_Cmd10(parts) {
    ; TODO
    return "ERR TODO"
}

; ── Lua 文件通道（无 luasocket 时写入 tcp_cmd.txt）──

PollCmdFile(*) {
    global CMD_FILE
    if !FileExist(CMD_FILE)
        return
    try {
        content := FileRead(CMD_FILE)
        FileDelete(CMD_FILE)
    } catch as e {
        Log("读取命令文件失败: " e.Message)
        return
    }
    for line in StrSplit(content, "`n", "`r") {
        line := Trim(line)
        if (line = "")
            continue
        Log("FILE IN: " line)
        resp := DispatchTcp(line)
        Log("FILE OUT: " resp)
    }
}

; ── TCP 服务 (lib\Socket.ahk) ──

StartTcpServer() {
    global ListenSocket
    ListenSocket := Socket.Server(TCP_PORT, TCP_HOST)
    ListenSocket.OnAccept := OnTcpAccept
}

OnTcpAccept(server, err, *) {
    global ListenSocket, Clients
    if err
        return
    loop {
        try
            client := ListenSocket.AcceptAsClient()
        catch
            break
        client.OnRead := OnTcpRead
        client.OnClose := OnTcpClose
        Clients[client.Ptr] := { buf: "", client: client }
    }
}

OnTcpRead(client, err, *) {
    global Clients
    if err || !Clients.Has(client.Ptr)
        return
    state := Clients[client.Ptr]
    try
        text := client.RecvText("cp0", 0)
    catch
        return OnTcpClose(client, 0)
    if (text = "")
        return
    state.buf .= text
    while (line := ExtractLine(state)) {
        resp := DispatchTcp(line)
        try
            client.SendText(resp "`n", "cp0")
        catch
            return OnTcpClose(client, 0)
    }
}

OnTcpClose(client, err, *) {
    global Clients
    Clients.Delete(client.Ptr)
    try client.Close()
}

ExtractLine(state) {
    pos := InStr(state.buf, "`n")
    if (!pos)
        return ""
    line := SubStr(state.buf, 1, pos - 1)
    state.buf := SubStr(state.buf, pos + 1)
    if (line ~= "`r$")
        line := RTrim(line, "`r")
    return line
}

DispatchTcp(line) {
    line := Trim(line)
    if (line = "")
        return "ERR empty"
    parts := StrSplit(line, A_Space, " `t", 32)
    cmd := StrUpper(parts[1])
    table := InitTcpHandlers()
    if (!table.Has(cmd))
        return "ERR unknown cmd: " cmd
    try
        return table[cmd].Call(parts)
    catch as e
        return "ERR " e.Message
}

Shutdown(*) {
    global ListenSocket, Clients
    for , state in Clients.Clone()
        try state.client.Close()
    Clients := Map()
    try ListenSocket.Close()
}
