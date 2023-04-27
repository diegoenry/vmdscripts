mol new     system.1.0.psf
mol addfile system.1.0.pdb

set sel [atomselect 0 protein]
$sel writepdb protein.pdb
$sel writepsf protein.psf

set file [open nowater.idx w]
puts $file [$sel get index]
close $file

set sel [atomselect 0 "noh protein"]
$sel writepdb protein_noH.pdb
$sel writepsf protein_noH.psf

set file [open nowater_noH.idx w]
puts $file [$sel get index]
close $file

quit


