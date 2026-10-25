# Create one AD user (password asked in hidden mode, never stored in the script)
$mdp = Read-Host -AsSecureString "Mot de passe"
New-ADUser -Name "Test Recette" -GivenName Test -Surname Recette -SamAccountName test.recette `
  -UserPrincipalName test.recette@lab.local `
  -Path "OU=INFORMATIQUE,OU=UTILISATEURS,DC=lab,DC=local" `
  -AccountPassword $mdp -Enabled $true -ChangePasswordAtLogon $false
