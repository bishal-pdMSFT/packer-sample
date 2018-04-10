Set-ExecutionPolicy Unrestricted

New-item -Path C:\NVM -ItemType Directory -Force
Copy-Item $PSScriptRoot\..\..\* C:\NVM\ -recurse -Force

# InstallIIS.ps1

# --------------------------------------------------------------------
# Define the variables.
# --------------------------------------------------------------------
$InetPubRoot = "C:\Inetpub"
$InetPubLog = "C:\Inetpub\Logs"
$InetPubWWWRoot = "C:\Inetpub\WWWRoot"

# --------------------------------------------------------------------
# Loading Feature Installation Modules
# --------------------------------------------------------------------
$Command = "icacls ..\ /grant ""Network Service"":(OI)(CI)W"
cmd.exe /c $Command
$Command = "icacls C:\NVM\ /grant ""Network Service"":(OI)(CI)W"
cmd.exe /c $Command

# --------------------------------------------------------------------
# Loading IIS Modules
# --------------------------------------------------------------------
Import-Module ServerManager 

# --------------------------------------------------------------------
# Installing IIS
# --------------------------------------------------------------------
$features = @(
   "Web-WebServer",
   "Web-Static-Content",
   "Web-Http-Errors",
   "Web-Http-Redirect",
   "Web-Stat-Compression",
   "Web-Filtering",
   "Web-Asp-Net45",
   "Web-Net-Ext45",
   "Web-ISAPI-Ext",
   "Web-ISAPI-Filter",
   "Web-Mgmt-Console",
   "Web-Mgmt-Tools",
   "NET-Framework-45-ASPNET"
)
Add-WindowsFeature $features -Verbose

# --------------------------------------------------------------------
# Loading IIS Modules
# --------------------------------------------------------------------
Import-Module WebAdministration

# --------------------------------------------------------------------
# Setting directory access
# --------------------------------------------------------------------
$Command = "icacls $InetPubWWWRoot /grant BUILTIN\IIS_IUSRS:(OI)(CI)(RX) BUILTIN\Users:(OI)(CI)(RX)"
cmd.exe /c $Command
$Command = "icacls $InetPubLog /grant ""NT SERVICE\TrustedInstaller"":(OI)(CI)(F)"
cmd.exe /c $Command

# --------------------------------------------------------------------
# Resetting IIS
# --------------------------------------------------------------------
$Command = "IISRESET"
Invoke-Expression -Command $Command

# Download.ps1

$runtimeUrl = "http://az413943.vo.msecnd.net/node/0.10.21.exe;http://nodertncu.blob.core.windows.net/iisnode/0.1.21.exe"

$overrideUrl = $args[1]
$current = [string] (Get-Location -PSProvider FileSystem)
$client = New-Object System.Net.WebClient

function downloadWithRetry {
	param([string]$url, [string]$dest, [int]$retry) 
	
    trap {
    	
	    if ($retry -lt 5) {
	    	$retry=$retry+1
	    	
	    	Start-Sleep -s 5
	    	downloadWithRetry $url $dest $retry $client
	    }

	    else {
	    	throw "Max number of retries downloading [5] exceeded" 	
	    }
    }
    $client.downloadfile($url, $dest)
}

function download($url, $dest) {
	downloadWithRetry $url $dest 1
}

function copyOnVerify($file, $output) {
  $verify = Get-AuthenticodeSignature $file
  Out-Host -InputObject $verify
  if ($verify.Status -ne "Valid") {
     throw "Invalid signature for runtime package $file"
  }
  else {
    mv $file $output
  }
}

function installUrlRewrite() {
	$suffix = Get-Random
	$downloaddir = $current + "\sandbox" + $suffix
	mkdir $downloaddir

	$iisrewriteurl = "http://go.microsoft.com/fwlink/?LinkID=615137"
	$outputfileName = "$downloaddir\rewrite_amd64.msi"
	download $iisrewriteurl $outputfileName

	cd $downloaddir
	$Command = "msiexec -i ""rewrite_amd64.msi"" /qn /quiet"
	cmd.exe /c $Command
    
    cd $current
    if (Test-Path -LiteralPath $downloaddir)
    {
        Remove-Item -LiteralPath $downloaddir -Force -Recurse
    }
}

if ($overrideUrl) {
    $url = $overrideUrl
}
else {
	$url = $runtimeUrl
}

foreach($singleUrl in $url -split ";") 
{
    $suffix = Get-Random
    $downloaddir = $current + "\sandbox" + $suffix
    mkdir $downloaddir
    $dest = $downloaddir + "\sandbox.exe"
    download $singleUrl $dest
	
    $final = $downloaddir + "\runtime.exe"
    copyOnVerify $dest $final
    if (Test-Path -LiteralPath $final)
    {
      cd $downloaddir
      if ($host.Version.Major -eq 3)
      {
        .\runtime.exe -y | Out-Null
        .\setup.cmd
      }
      else
      {
        Start-Process -FilePath $final -ArgumentList -y -Wait 
        $cmd = $downloaddir + "\setup.cmd"
        Start-Process -FilePath $cmd -Wait
      }
    }
    else
    {
      throw "Unable to verify package"
    }



    cd $current
    if (Test-Path -LiteralPath $downloaddir)
    {
        Remove-Item -LiteralPath $downloaddir -Force -Recurse
    }
}

installUrlRewrite

#SetupWeb.ps1

Set-ExecutionPolicy Unrestricted

if(Get-Website -Name "Default Web Site")
{
    Remove-WebSite -Name "Default Web Site"
}

if(Get-Website -Name "NodeApp")
{
	Remove-WebSite -Name "NodeApp"
}

if(Test-Path "IIS:\AppPools\NodeAppPool")
{
  Remove-WebAppPool "NodeAppPool"
}

New-WebAppPool NodeAppPool -Force
Start-WebAppPool -Name NodeAppPool

New-WebSite -Name NodeApp -Port 80 -PhysicalPath "$env:systemdrive\NVM" -ApplicationPool NodeAppPool  -Force
Start-WebSite -Name "NodeApp"
