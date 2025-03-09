# Script de Gestão de Ativos de Equipamentos no Domínio (Compatível com Windows Server 2019)

Import-Module ActiveDirectory

# Configuração do domínio
$domain = "japa.com.br"
$baseOU = "japa.com.br"

# Função para exibir o menu
function Show-Menu {
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
}

# Função para gerar uma senha forte e compatível com as políticas do AD
function Gerar-Senha {
    param ([int]$tamanho = 14)
    $maiusculas = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $minusculas = "abcdefghijklmnopqrstuvwxyz"
    $numeros = "0123456789"
    $especiais = "@#$%^&*-_+="
    
    $senha = -join (
        (Get-Random -InputObject $maiusculas) +
        (Get-Random -InputObject $minusculas) +
        (Get-Random -InputObject $numeros) +
        (Get-Random -InputObject $especiais) +
        (-join ((1..($tamanho-4)) | ForEach-Object { Get-Random -InputObject ($maiusculas + $minusculas + $numeros + $especiais) }))
    )
    return $senha
}

# Função para criar um usuário no AD
function Criar-Usuario {
    try {
        $primeiroNome = Read-Host "Digite o primeiro nome do usuário"
        $sobrenome = Read-Host "Digite o sobrenome do usuário"
        $matricula = Read-Host "Digite a matrícula JAPAEMPRESA"
        $centroCusto = Read-Host "Digite o centro de custo"
        $cargo = Read-Host "Digite o cargo na JAPAEMPRESA"
        $ramal = Read-Host "Digite o ramal"
        $email = Read-Host "Digite o e-mail JAPAEMPRESA"
        $nomeUsuario = Read-Host "Digite o nome de usuário (login)"
        $setor = Read-Host "Digite o setor (ex: TI, RH, Financeiro)"

        # Verifica se a OU do setor existe no AD
        $ouPath = "OU=$setor,OU=JAPA,DC=japa,DC=com,DC=br"
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'")) {
            Write-Host "Erro: A OU '$setor' não existe no Active Directory." -ForegroundColor Red
            return
        }

        # Verifica se o usuário já existe
        if (Get-ADUser -Filter {SamAccountName -eq $nomeUsuario}) {
            Write-Host "Erro: O usuário '$nomeUsuario' já existe no AD." -ForegroundColor Red
            return
        }

        # Gera uma senha segura caso o usuário não forneça uma
        $senha = Read-Host "Digite uma senha forte (ou pressione Enter para gerar automaticamente)" -AsSecureString
        if (-not $senha) {
            $senhaTexto = Gerar-Senha 14
            $senha = ConvertTo-SecureString $senhaTexto -AsPlainText -Force
            Write-Host "Senha gerada automaticamente: $senhaTexto (altere no primeiro login)" -ForegroundColor Yellow
        }

        # Criação do usuário no AD
        New-ADUser `
            -Name "$primeiroNome $sobrenome" `
            -GivenName "$primeiroNome" `
            -Surname "$sobrenome" `
            -SamAccountName "$nomeUsuario" `
            -UserPrincipalName "$nomeUsuario@japa.com.br" `
            -EmailAddress "$email" `
            -Description "$cargo" `
            -OfficePhone "$ramal" `
            -Path "$ouPath" `
            -AccountPassword $senha `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Usuário '$nomeUsuario' criado com sucesso em $ouPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Erro ao criar usuário: $_" -ForegroundColor Red
    }
}

# Execução do menu
Show-Menu
