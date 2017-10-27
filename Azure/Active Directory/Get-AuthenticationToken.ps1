﻿Function Get-AuthenticationToken {

  <#
      .SYNOPSIS
      This function is used to get an authentication token for the Graph API REST interface
      .DESCRIPTION
      Built based on the following example script from Microsoft: https://github.com/microsoftgraph/powershell-intune-samples/blob/master/Authentication/Auth_From_File.ps1
      .EXAMPLE
      $Credential = Get-Credential
      $ClientId = 'f338765e-1cg71-427c-a14a-f3d542442dd'
      $AuthToken = Get-AuthenticationToken -Credential $Credential -ClientId $ClientId
  #>
  [cmdletbinding()]
  
  param
  (
      [Parameter(Mandatory=$true)]
      $Credential,
      $ClientId
  )
  
  Write-Verbose 'Importing prerequisite modules...'
  
  try {
  
      $AadModule = Import-Module -Name AzureAD -ErrorAction Stop -PassThru
  
  }
  
  catch {
  
      throw 'Prerequisites not installed (AzureAD PowerShell module not installed'
  
  }

  $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $Credential.Username
  
  $tenant = $userUpn.Host
    
  
  # Getting path to ActiveDirectory Assemblies
  # If the module count is greater than 1 find the latest version
  
  $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
  $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
   
  
  [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  
  [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
  
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  
  $resourceAppIdURI = "https://graph.microsoft.com"
  
  $authority = "https://login.microsoftonline.com/$Tenant"
  
      try {
  
      $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
  
      # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
      # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
  
      $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
  
      $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($Credential.Username, "OptionalDisplayableId")
  
   
              $userCredentials = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $Credential.Username,$Credential.GetNetworkCredential().Password
  
              $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceAppIdURI, $clientid, $userCredentials).Result;
  
  
          if($authResult.AccessToken){
  
          # Creating header for Authorization token
  
          $authHeader = @{
              'Content-Type'='application/json'
              'Authorization'="Bearer " + $authResult.AccessToken
              'ExpiresOn'=$authResult.ExpiresOn
              }
  
          return $authHeader
  
          }
  
  
  
      }
  
      catch {
  
          throw $_.Exception.Message 
      
      }
  
  }