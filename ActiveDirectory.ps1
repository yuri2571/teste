# Importa o módulo do Active Directory
Import-Module ActiveDirectory

# Função para gerar uma senha aleatória forte
function Gerar-Senha {
    param (
        [int]$tamanho = 12
    )
    $caracteres = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
    -join ((1..$tamanho) | ForEach-Object { Get-Random -Maximum $caracteres.Length } | ForEach-Object { $caracteres[$_] })
}

# Função para criar um novo usuário no Active Directory
function Criar-Usuario {
    try {
        # Solicita as informações do usuário
        $primeiroNome = Read-Host "Digite o primeiro nome do usuário"
        $sobrenome = Read-Host "Digite o sobrenome do usuário"
        $matricula = Read-Host "Digite a matrícula JAPAEMPRESA"
        $centroCusto = Read-Host "Digite o centro de custo"
        $cargo = Read-Host "Digite o cargo na JAPAEMPRESA"
        $ramal = Read-Host "Digite o ramal"
        $email = Read-Host "Digite o e-mail JAPAEMPRESA"
        $nomeUsuario = Read-Host "Digite o nome de usuário (login)"
        $setor = Read-Host "Digite o setor (ex: TI, RH, Financeiro)"
        
        # Valida se o setor informado existe no AD
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

        # Solicita ou gera automaticamente uma senha segura
        $senha = Read-Host "Digite uma senha forte (ou pressione Enter para gerar automaticamente)" -AsSecureString
        if (-not $senha) {
            $senhaTexto = Gerar-Senha 14
            $senha = ConvertTo-SecureString $senhaTexto -AsPlainText -Force
            Write-Host "Senha gerada automaticamente: $senhaTexto (altere no primeiro login)" -ForegroundColor Yellow
        }

        # Cria o usuário no AD
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

# Executa a função
Criar-Usuario
