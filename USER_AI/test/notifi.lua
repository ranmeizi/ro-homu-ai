os.execute([[
    powershell -Command "$notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(5000, 'Notification Title', 'This is a notification message!', [System.Windows.Forms.ToolTipIcon]::Info)"
]])