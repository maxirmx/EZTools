# --------------------------------------------------------------------
# This powershell script is a part of Project Û
# It invokes a shell script and clones its environment in the parent shell.
# (It is used to call vcvarsall.bat for given environment and save configuration)
# --------------------------------------------------------------------

param(
#  scriptName:        yes, it is the script name 
    [parameter(Mandatory=$true)][string]  $scriptName,
#  scriptArgs:        script arguments 
    [parameter(Mandatory=$false)][string] $scriptArgs
)

$cmdLine = """$scriptName"" $scriptArgs & set"

& $Env:SystemRoot\system32\cmd.exe /c $cmdLine |
select-string '^([^=]*)=(.*)$' | 
foreach-object {
	$varName = $_.Matches[0].Groups[1].Value
	$varValue = $_.Matches[0].Groups[2].Value
	set-item Env:$varName $varValue
}
