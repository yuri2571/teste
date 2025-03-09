# Importa o m�dulo do Active Directory
Import-Module ActiveDirectory

# Fun��o para gerar uma senha aleat�ria forte
function Gerar-Senha {
    param (
        [int]$tamanho = 12
    )
    $caracteres = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
    -join ((1..$tamanho) | ForEach-Object { Get-Random -Maximum $caracteres.Length } | ForEach-Object { $caracteres[$_] })
}

# Fun��o para criar um novo usu�rio no Active Directory
function Criar-Usuario {
    try {
        # Solicita as informa��es do usu�rio
        $primeiroNome = Read-Host "Digite o primeiro nome do usu�rio"
        $sobrenome = Read-Host "Digite o sobrenome do usu�rio"
        $matricula = Read-Host "Digite a matr�cula JAPAEMPRESA"
        $centroCusto = Read-Host "Digite o centro de custo"
        $cargo = Read-Host "Digite o cargo na JAPAEMPRESA"
        $ramal = Read-Host "Digite o ramal"
        $email = Read-Host "Digite o e-mail JAPAEMPRESA"
        $nomeUsuario = Read-Host "Digite o nome de usu�rio (login)"
        $setor = Read-Host "Digite o setor (ex: TI, RH, Financeiro)"
        
        # Valida se o setor informado existe no AD
        $ouPath = "OU=$setor,OU=JAPA,DC=japa,DC=com,DC=br"
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'")) {
            Write-Host "Erro: A OU '$setor' n�o existe no Active Directory." -ForegroundColor Red
            return
        }

        # Verifica se o usu�rio j� existe
        if (Get-ADUser -Filter {SamAccountName -eq $nomeUsuario}) {
            Write-Host "Erro: O usu�rio '$nomeUsuario' j� existe no AD." -ForegroundColor Red
            return
        }

        # Solicita ou gera automaticamente uma senha segura
        $senha = Read-Host "Digite uma senha forte (ou pressione Enter para gerar automaticamente)" -AsSecureString
        if (-not $senha) {
            $senhaTexto = Gerar-Senha 14
            $senha = ConvertTo-SecureString $senhaTexto -AsPlainText -Force
            Write-Host "Senha gerada automaticamente: $senhaTexto (altere no primeiro login)" -ForegroundColor Yellow
        }

        # Cria o usu�rio no AD
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
        
        Write-Host "Usu�rio '$nomeUsuario' criado com sucesso em $ouPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Erro ao criar usu�rio: $_" -ForegroundColor Red
    }
}

# Executa a fun��o
Criar-Usuario
