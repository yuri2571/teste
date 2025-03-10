# Script de Gestão de Ativos de Equipamentos no Domínio (Compatível com Windows Server 2019)

Import-Module ActiveDirectory

# Configuração do domínio
$domain = "japa.com.br"
$baseOU = "japa.com.br"

# Função para exibir o menu e capturar a entrada do usuário corretamente
function Show-Menu {
    do {
        Clear-Host
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host "          MENU DE GERENCIAMENTO AD            " -ForegroundColor Yellow
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host " Domínio: $domain" -ForegroundColor Green
        Write-Host "--------------------------------------------------------------"
        Write-Host "1 - Criar usuario no AD" -ForegroundColor White
        Write-Host "2 - Inativar usuario no AD" -ForegroundColor White
        Write-Host "3 - Reativar usuario no AD" -ForegroundColor White
        Write-Host "4 - Deletar usuario" -ForegroundColor White
        Write-Host "5 - Resetar a senha" -ForegroundColor White
        Write-Host "6 - Desbloquear usuario" -ForegroundColor White
        Write-Host "7 - Associar computador no AD" -ForegroundColor White
        Write-Host "8 - Desassociar computador" -ForegroundColor White
        Write-Host "9 - Deletar computador" -ForegroundColor White
        Write-Host "10 - Alterar ramal" -ForegroundColor White
        Write-Host "11 - Sincronizar AD" -ForegroundColor White
        Write-Host "12 - Listar usuarios" -ForegroundColor White
        Write-Host "13 - Listar computadores" -ForegroundColor White
        Write-Host "14 - Mover objeto para outra OU" -ForegroundColor White
        Write-Host "15 - Adicionar usuario a um grupo" -ForegroundColor White
        Write-Host "16 - Remover usuario de um grupo" -ForegroundColor White
        Write-Host "17 - Verificar membros de um grupo" -ForegroundColor White
        Write-Host "18 - Alterar atributos de um usuario" -ForegroundColor White
        Write-Host "19 - Exportar relatorio de usuarios" -ForegroundColor White
        Write-Host "20 - Exportar relatorio de computadores" -ForegroundColor White
        Write-Host "21 - Exportar relatorio de grupos" -ForegroundColor White
        Write-Host "0 - Sair do script" -ForegroundColor Red
        Write-Host "==============================================" -ForegroundColor Cyan

        # Captura a entrada do usuário
        $opcao = Read-Host "Digite o número da opção desejada"

        # Processa a opção escolhida
        switch ($opcao) {
            "1" { Criar-Usuario }
            "2" { Disable-ADAccount -Identity (Read-Host "Digite o nome do usuário") }
            "3" { Enable-ADAccount -Identity (Read-Host "Digite o nome do usuário") }
            "4" { Remove-ADUser -Identity (Read-Host "Digite o nome do usuário") -Confirm:$false }
            "5" { Set-ADAccountPassword -Identity (Read-Host "Digite o nome do usuário") -Reset -NewPassword (ConvertTo-SecureString -AsPlainText (Read-Host "Digite a nova senha") -Force) }
            "6" { Unlock-ADAccount -Identity (Read-Host "Digite o nome do usuário") }
            "7" { Add-Computer -DomainName $domain -Credential (Get-Credential) }
            "8" { Remove-Computer -UnjoinDomainCredential (Get-Credential) -Force -Restart }
            "9" { Remove-ADComputer -Identity (Read-Host "Digite o nome do computador") -Confirm:$false }
            "10" { Set-ADUser -Identity (Read-Host "Digite o nome do usuário") -OfficePhone (Read-Host "Digite o novo ramal") }
            "11" { gpupdate /force }
            "12" { Get-ADUser -Filter * | Select-Object Name, SamAccountName }
            "13" { Get-ADComputer -Filter * | Select-Object Name, OperatingSystem }
            "14" { Move-ADObject -Identity (Read-Host "Digite o nome do objeto") -TargetPath (Read-Host "Digite a nova OU") }
            "15" { Add-ADGroupMember -Identity (Read-Host "Digite o nome do grupo") -Members (Read-Host "Digite o nome do usuário") }
            "16" { Remove-ADGroupMember -Identity (Read-Host "Digite o nome do grupo") -Members (Read-Host "Digite o nome do usuário") -Confirm:$false }
            "17" { Get-ADGroupMember -Identity (Read-Host "Digite o nome do grupo") | Select-Object Name }
            "18" { Set-ADUser -Identity (Read-Host "Digite o nome do usuário") -Title (Read-Host "Digite o novo cargo") }
            "19" { Get-ADUser -Filter * | Export-Csv -Path "C:\Relatorio_Usuarios.csv" -NoTypeInformation }
            "20" { Get-ADComputer -Filter * | Export-Csv -Path "C:\Relatorio_Computadores.csv" -NoTypeInformation }
            "21" { Get-ADGroup -Filter * | Export-Csv -Path "C:\Relatorio_Grupos.csv" -NoTypeInformation }
            "0" { Write-Host "Saindo do script..." -ForegroundColor Red; exit }
            default { Write-Host "Opção inválida! Tente novamente." -ForegroundColor Red }
        }
        
        # Aguarda antes de exibir o menu novamente
        Pause
    } while ($true)
}

# Chama a função para exibir o menu
Show-Menu
