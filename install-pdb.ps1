# --------------------------------------------------------------------
# This powershaell script is a part of Проект Ы
# It look for PDB files for all targets deploy tree and
# copies such PDBs from build folder to deploy folder if found.
# --------------------------------------------------------------------

Param (
#  deployRoot:        a root folder of deploy (install) tree  
 [parameter(Mandatory=$true)][string]$deployRoot,
#  buildRoot:         a root folder of build tree  
 [parameter(Mandatory=$true)][string]$buildRoot,
#  Subst: 	      a list of (optional) substitutions
 [parameter(Mandatory=$false)][string[]]$Subst
#     install-pdb.ps1 ./d ./podofo/build  podofo,podofo_static
#     would install PDBs from ./podofo/build  to ./d but podofo.pdb if not found would be 
#     actually a copy of podofo_static.pdb       
#     install-pdb.ps1 ./d ./podofo/build  a,not_a,podofo,podofo_static would create 
#     two substitutions a->not_a and podofo->podofo_static
)


# Compile a list of all targets in the deploy tree
# File name and target destination 
$Targets = dir -Path $deployRoot  -Include *.dll,*.lib,*.exe -Recurse | %{$_.BaseName, $_.DirectoryName}

# Compile a list of all pdb files the build tree
# Full paths
$PDBs = dir -Path $buildRoot  -Include *.pdb  -Recurse | %{$_.FullName}

for ($i=0; $i -lt $Targets.count; $i+=2) {
# .pdb is required otherwise it may find folder name or some other file 
  $filter = $Targets[$i] + ".pdb"

  for ($j=0; $j -lt $Subst.count; $j+=2) {
#    $Targets[$i] + " ? " + $Subst[$j] + " --> " + $Subst[$j+1]
    if ($Targets[$i] -eq $Subst[$j]) {
     $filter = $Subst[$j+1]
     "Applying substitution <" + $Targets[$i] + ".pdb> to <" + $Subst[$j+1] + ".pdb>." 
    }
  }

  $match = $PDBs -match $filter
  if ($null -ne $match -and $match.count -gt 0) {
    "Found PDB: <" + $match[0] + "> for target <" + $filter +">. Copying to: <" + $Targets[$i+1] + "\" + $Targets[$i] + ".pdb" + ">."
    Copy-Item   -Path $match[0] -Destination ($Targets[$i+1] + "\" + $Targets[$i] + ".pdb") -Force
  } else {
    "No PDB for <" + $filter + ">. Skipping." 
  }
}





