Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Net.NetworkInformation

#create form
$form = New-Object System.Windows.Forms.Form
$form.Text= "Ping Pc..."
$form.Size = New-Object System.Drawing.Size(385, 150)
$form.StartPosition = 'CenterScreen'
$form.MaximumSize  = $form.Size
$form.MinimumSize  = $form.Size
$form.KeyPreview = $true
$form.Add_KeyDown({
switch ($_.KeyCode)
{
    "Escape"
    {
        btn_cancelar_click
    }
}
})

$lbl_ip = New-Object System.Windows.Forms.Label
$lbl_ip.AutoSize = $true
$lbl_ip.Text = "Dirección IP del ordenador"
$lbl_ip.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($lbl_ip)

$txt_ip = New-Object System.Windows.Forms.TextBox
$txt_ip.Width = 200
$txt_ip.Location = New-Object System.Drawing.Point(13, 30)
$txt_ip.Add_KeyDown({if($_.KeyCode -eq "Enter"){btn_enviar_click}})
$form.Controls.Add($txt_ip)

$check_apagar = New-Object System.Windows.Forms.CheckBox
$check_apagar.Text = "Apagar la pc"
$check_apagar.Location = New-Object System.Drawing.Point(13, 50)
$form.Controls.Add($check_apagar)

$check_mensaje = New-Object System.Windows.Forms.CheckBox
$check_mensaje.Text = "Enviar mensaje"
$check_mensaje.Location = New-Object System.Drawing.Point(120, 50)
$check_mensaje.Add_Click($check_mensaje_click)
$form.Controls.Add($check_mensaje)

$status_bar = New-Object System.Windows.Forms.StatusBar
$status_bar.Text = "Listo..."
$form.Controls.Add($status_bar)

$btn_enviar = New-Object System.Windows.Forms.Button
$btn_enviar.Text = "Enviar"
$btn_enviar.Size = New-Object System.Drawing.Size(65, 23)
$btn_enviar.Location = New-Object System.Drawing.Point(220, 28)
$btn_enviar.Add_Click({btn_enviar_click})
$form.Controls.Add($btn_enviar)

$btn_cancelar = New-Object System.Windows.Forms.Button
$btn_cancelar.Text = "Cancelar"
$btn_cancelar.Size = New-Object System.Drawing.Size(65, 23)
$btn_cancelar.Location = New-Object System.Drawing.Point(290, 28)
$btn_cancelar.Add_Click({btn_cancelar_click})
$form.Controls.Add($btn_cancelar)

$lbl_mensaje = New-Object System.Windows.Forms.Label
$lbl_mensaje.Visible = $false
$lbl_mensaje.AutoSize = $true
$lbl_mensaje.Text = "Texto del mensaje"
$lbl_mensaje.Location = New-Object System.Drawing.Point(10, 93)
$form.Controls.Add($lbl_mensaje)

$txt_mensaje = New-Object System.Windows.Forms.TextBox
$txt_mensaje.Visible = $false
$txt_mensaje.Multiline = $true
$txt_mensaje.Location = New-Object System.Drawing.Point(13, 110)
$txt_mensaje.Size = New-Object System.Drawing.Size(340, 200)
$form.Controls.Add($txt_mensaje)

$check_mensaje_click = {
if($check_mensaje.Checked -eq $true){
    
    $form.MaximumSize  = New-Object System.Drawing.Size(385, 385)
    $form.MinimumSize  = New-Object System.Drawing.Size(385, 385)
    $form.Size = New-Object System.Drawing.Size(385, 385)
    $lbl_mensaje.Visible = $true
    $lbl_mensaje.Update()
    $txt_mensaje.Visible = $true
    $txt_mensaje.Update()
    $form.Update()
}
else{
    $form.MaximumSize  = New-Object System.Drawing.Size(385, 150)
    $form.MinimumSize  = New-Object System.Drawing.Size(385, 150)
    $form.Size = New-Object System.Drawing.Size(385, 150)
    $lbl_mensaje.Visible = $false
    $lbl_mensaje.Update()
    $txt_mensaje.Visible = $false
    $txt_mensaje.Update()
    $form.Update()
}
}
function btn_cancelar_click() {$form.Close()}
function btn_enviar_click() {
    if($txt_ip.Text -eq ""){
        [System.Windows.MessageBox]::Show("No se ha introducido una dirección de IP")
        return
    }
    $pc = $txt_ip.Text
    $ping_flag = $false
    if (Test-Connection $pc -quiet -Count 1){
        Write-Host -ForegroundColor Green "El ordenador $pc se encuentra disponible"
        $status_bar.Text = "Tarea completada satisfactoriamente con $pc"
        $ping_flag = $true}
    else{
        Write-Host -ForegroundColor Red "El ordenador $pc no se encuentra disponible"
        $status_bar.Text = "No se pudo completar la tarea, $pc inaccesible"}   

    if($ping_flag){
        if($check_mensaje.Checked){
            $pc = $txt_ip.Text
            $mensaje = $txt_mensaje.Text
            $j = Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $mensaje" -ComputerName $pc
            $result = $j | Receive-Job
            Write-Host -ForegroundColor White "Mensaje enviado con éxito"
        }
        if($check_apagar.Checked){
            $computername= $txt_ip.Text
            $win32OS = get-wmiobject win32_operatingsystem -computername $computername -EnableAllPrivileges
            $win32OS.psbase.Scope.Options.EnablePrivileges = $true
            if($win32OS.win32shutdown(8) -eq 0){
                Write-Host "Equipo Apagado"}
            else{
                Write-Host "Se ha producido un error, tarea no completada"}
        }
    }
}

cls
$form.TopMost= $True
$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()
