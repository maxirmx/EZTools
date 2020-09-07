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
#     would install PDBs from ./podofo/build  to ./d but podofo_static.pdb would be used for podofo.pdb 
#     install-pdb.ps1 ./d ./podofo/build  a,not_a,podofo,podofo_static would create 
#     two matches a->not_a and podofo->podofo_static
)


# Compile a list of all targets in the deploy tree
# File name and target destination 
$Targets = dir -Path $deployRoot  -Include *.dll,*.lib,*.exe -Recurse | %{$_.BaseName, $_.DirectoryName}

# Compile a list of all pdb files the build tree
# Full paths
$PDBs = dir -Path $buildRoot  -Include *.pdb  -Recurse | %{$_.FullName}

# PDBs ought to be an array
# This is for the case when only single PDB file was found
if ($PDBs -isnot [system.array]) {
 $PDBs = ,$PDBs
}

for ($i=0; $i -lt $Targets.count; $i+=2) {
  $filter = "-- nothing --"

  for ($j=0; $j -lt $Subst.count; $j+=2) {
#    $Targets[$i] + " ? " + $Subst[$j] + " --> " + $Subst[$j+1]
    if ($Targets[$i] -eq $Subst[$j]) {
     $filter = $Subst[$j+1]
     "Applying substitution <" + $Targets[$i] + ".pdb> to <" + $Subst[$j+1] + ".pdb>." 
    }
  }

  if ($filter -eq "-- nothing --") {
    $filter = $Targets[$i]
  }

# .pdb is required otherwise it may find folder name or some other file 
  $filter = $filter  + ".pdb"

  $match = $PDBs -match $filter
  if ($null -ne $match -and $match.count -gt 0) {
    "Found PDB: <" + $match[0] + "> for target <" + $Targets[$i] +">. Copying to: <" + $Targets[$i+1] + "\" + $filter + ">."
    Copy-Item   -Path $match[0] -Destination ($Targets[$i+1] + "\" + $match[0] + ".pdb") -Force
  } else {
    "No PDB for <" + $Targets[$i] + ">. Skipping." 
  }
}





