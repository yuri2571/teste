# Configuração do Servidor Samba AD
$LDAPServer = "ldap://192.168.10.20"  # Substitua pelo endereço do seu servidor Samba AD
$LDAPBaseDN = "DC=japaempresa,DC=local"   # Substitua pelo seu domínio
$AdminUser = "administrator@japaempresa.local"        # Usuário administrador do Samba AD
$AdminPassword = "Yuri@9508"         # Senha do administrador

# Função para Criar um Usuário no Samba AD via LDAP
function Criar-Usuario {
    try {
        # Solicita informações do usuário
        $primeiroNome = Read-Host "Digite o primeiro nome do usuário"
        $sobrenome = Read-Host "Digite o sobrenome do usuário"
        $nomeUsuario = Read-Host "Digite o nome de usuário (login)"
        $email = Read-Host "Digite o e-mail"
        $cargo = Read-Host "Digite o cargo"
        $setor = Read-Host "Digite o setor (ex: TI, RH, Financeiro)"

        # Define o caminho da OU do usuário
        $ouPath = "OU=$setor,OU=JAPA,$LDAPBaseDN"

        # Verifica se a OU existe no Samba AD
        $SearchOU = New-Object DirectoryServices.DirectorySearcher
        $SearchOU.SearchRoot = New-Object DirectoryServices.DirectoryEntry($LDAPServer, $AdminUser, $AdminPassword)
        $SearchOU.Filter = "(distinguishedName=$ouPath)"
        $OUExists = $SearchOU.FindOne()

        if (-not $OUExists) {
            Write-Host "Erro: A OU '$setor' não existe no Samba AD." -ForegroundColor Red
            return
        }

        # Verifica se o usuário já existe
        $SearchUser = New-Object DirectoryServices.DirectorySearcher
        $SearchUser.SearchRoot = New-Object DirectoryServices.DirectoryEntry($LDAPServer, $AdminUser, $AdminPassword)
        $SearchUser.Filter = "(sAMAccountName=$nomeUsuario)"
        $UserExists = $SearchUser.FindOne()

        if ($UserExists) {
            Write-Host "Erro: O usuário '$nomeUsuario' já existe no Samba AD." -ForegroundColor Red
            return
        }

        # Conecta ao Samba AD
        $LDAPEntry = New-Object DirectoryServices.DirectoryEntry($LDAPServer, $AdminUser, $AdminPassword)
        $UserDN = "CN=$primeiroNome $sobrenome,$ouPath"

        # Cria a conta do usuário
        $NewUser = $LDAPEntry.Create("user", $UserDN)
        $NewUser.Put("objectClass", "user")
        $NewUser.Put("sAMAccountName", $nomeUsuario)
        $NewUser.Put("givenName", $primeiroNome)
        $NewUser.Put("sn", $sobrenome)
        $NewUser.Put("mail", $email)
        $NewUser.Put("description", $cargo)
        $NewUser.SetInfo()

        # Define a senha do usuário
        $senha = "Senha@123"  # Defina uma senha inicial
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($senha)
        $base64 = [Convert]::ToBase64String($bytes)
        $NewUser.Put("unicodePwd", $base64)
        $NewUser.SetInfo()

        Write-Host "Usuário '$nomeUsuario' criado com sucesso na OU '$setor'!" -ForegroundColor Green
    }
    catch {
        Write-Host "Erro ao criar usuário: $_" -ForegroundColor Red
    }
}

# Executar a função
Criar-Usuario
