$sysprep = 'C:\Windows\System32\Sysprep\Sysprep.exe'
$arg = '/generalize /oobe /shutdown /quiet'
$sysprep += " $arg" 
Invoke-Expression $sysprep