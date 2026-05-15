#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode('Mouse', 'Screen')

/**
 * UI 流程：逐项显示提示，用户在目标处点一下左键，记录屏幕坐标到该项的 x、y。
 * 提示条使用 +AlwaysOnTop 置顶；+E0x20 鼠标穿透，避免挡住你要点的区域。
 */
click_pos := [
    { tips: '请点击左手柄操作盘的坐标' },
    { tips: '请点击右手柄操作盘的坐标' },
    { tips: '请点击上手柄操作盘的坐标' },
    { tips: '请点击下手柄操作盘的坐标' },
]

g := Gui('+AlwaysOnTop +ToolWindow -Caption +Border +E0x20', '点击校准')
g.MarginX := 16
g.MarginY := 10
g.SetFont('s12', 'Segoe UI')
tipCtl := g.Add('Text', 'w720 Center', '')
g.Show('Hide')

WaitScreenLClick() {
    loop {
        if !GetKeyState('LButton', 'P') {
            Sleep(15)
            continue
        }
        MouseGetPos(&mx, &my)
        KeyWait('LButton')
        return { x: mx, y: my }
    }
}

for item in click_pos {
    tipCtl.Value := item.tips
    g.Show('NoActivate x' . (A_ScreenWidth - 760) // 2 . ' y8')
    p := WaitScreenLClick()
    item.x := p.x
    item.y := p.y
}

g.Destroy()

out := ''
for item in click_pos
    out .= item.tips ' → x=' item.x ' y=' item.y '`n`n'
MsgBox(out, '校准完成', 'Iconi')
