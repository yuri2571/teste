# Configura��o do Servidor AD Linux
$servidor = "seu-servidor-ad"
$usuario = "admin"
$senha = "sua-senha"

# Criar a Sess�o SSH no Linux
$senhaSec = ConvertTo-SecureString $senha -AsPlainText -Force
$Credenciais = New-Object System.Management.Automation.PSCredential ($usuario, $senhaSec)

# Menu
function Show-Menu {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "      Gerenciamento do Samba AD (Linux)      "
    Write-Host "=============================================="
    Write-Host "1 - Criar usu�rio no AD"
    Write-Host "2 - Inativar usu�rio no AD"
    Write-Host "3 - Reativar usu�rio no AD"
    Write-Host "4 - Deletar usu�rio"
    Write-Host "5 - Sair"
    Write-Host "=============================================="
    $choice = Read-Host "Escolha uma op��o"
    return $choice
}

# Fun��es de Gerenciamento no Linux
function Criar-Usuario {
    $user = Read-Host "Digite o nome do usu�rio"
    $senhaUser = Read-Host "Digite a senha do usu�rio"
    $comando = "sudo samba-tool user add $user '$senhaUser' --given-name='$user' --surname='$user'"
    Invoke-Command -ScriptBlock { param($c) ssh $using:usuario@$using:servidor $c } -ArgumentList $comando
    Write-Host "Usu�rio $user criado com sucesso!"
}

function Inativar-Usuario {
    $user = Read-Host "Digite o nome do usu�rio"
    $comando = "sudo samba-tool user disable $user"
    Invoke-Command -ScriptBlock { param($c) ssh $using:usuario@$using:servidor $c } -ArgumentList $comando
    Write-Host "Usu�rio $user inativado!"
}

function Reativar-Usuario {
    $user = Read-Host "Digite o nome do usu�rio"
    $comando = "sudo samba-tool user enable $user"
    Invoke-Command -ScriptBlock { param($c) ssh $using:usuario@$using:servidor $c } -ArgumentList $comando
    Write-Host "Usu�rio $user reativado!"
}

function Deletar-Usuario {
    $user = Read-Host "Digite o nome do usu�rio"
    $comando = "sudo samba-tool user delete $user"
    Invoke-Command -ScriptBlock { param($c) ssh $using:usuario@$using:servidor $c } -ArgumentList $comando
    Write-Host "Usu�rio $user deletado!"
}

# Loop do Menu
while ($true) {
    $choice = Show-Menu
    switch ($choice) {
        1 { Criar-Usuario }
        2 { Inativar-Usuario }
        3 { Reativar-Usuario }
        4 { Deletar-Usuario }
        5 { Write-Host "Saindo..."; exit }
        default { Write-Host "Op��o inv�lida!" }
    }
    Pause
}
