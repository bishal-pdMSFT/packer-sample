Param(
    [string]$target,
    [string]$shouldFail
    )

New-Item -Path . -Name $target -ItemType Directory -Force
Copy-Item .\dummy.zip $target -Force

if($shouldFail -ne $null)
{
    Write-Verbose -Verbose "some success message!!"
}
else
{
    throw "some error message"
}

ls