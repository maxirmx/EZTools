# --------------------------------------------------------------------
# This powershaell script is a part of Project Û
# It is used  to load and extract a library from one of maxirmx repos
# --------------------------------------------------------------------

param (
   [parameter(Mandatory=$true)][string]$libname,
#  platform: either 'X64' or 'x86'
#            'amd64' is accepted as well and converted to 'X64'
   [parameter(Mandatory=$false)][string]$platform="X64",
#  platform: either 'debug' or 'release'
   [parameter(Mandatory=$false)][string]$configuration="debug"
)


switch($platform) {
   "X64"   { break; } 
   "x86"   { break; } 
   "amd64" { $platform = "X64"; break; } 
   default { "load-libraries.ps1: platform `"$platform`" was not recognized"; exit (-1);  } 
}

switch($configuration) {
   "release"   { break; } 
   "debug"     { break; } 
   default     { "load-libraries.ps1: configuration `"$configuration`" was not recognized"; exit (-1);  } 
}


$fname   = "$libname.zip"
$fname_r = "$libname-$platform-$configuration.zip"
$dname   =  $libname
$uri     = "https://github.com/maxirmx/Dist_$libname/releases/latest/download/$fname_r"

Write-Host "`nLoading $uri into $dname/$fname `n"

New-Item -ItemType Directory -Force -Path $dname

Set-Location -Path $dname

try {
 Invoke-WebRequest -Uri $uri -ErrorAction Stop -OutFile $fname
} catch {
 "load-libraries.ps1 failed to access or load from uri `"$uri`""; 
 Set-Location -Path ..
 exit (-2);
}

& "C:\Program Files\7-Zip\7z" -tzip -aoa x $fname
Remove-Item $fname

Set-Location -Path ..


