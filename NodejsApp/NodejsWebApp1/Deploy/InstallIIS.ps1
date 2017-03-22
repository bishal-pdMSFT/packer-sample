Set-ExecutionPolicy Unrestricted

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