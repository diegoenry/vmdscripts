############################################################################
#cr
#cr            (C) Copyright 1995-2024 The Board of Trustees of the
#cr                        University of Illinois
#cr                         All Rights Reserved
#cr
############################################################################

############################################################################
# RCS INFORMATION:
#
#       $RCSfile: stride_by_pfrag.tcl,v $
#       $Author: dgomes $        $Locker:  $             $State: Exp $
#       $Revision: 0.1 $         $Date: 2023/08/28 09:15:56 $
#
############################################################################
#
# VMD stride by pfrag $Revision: 0.1 $
#
#
# Script to compute the secondary structure using STRIDE, by splitting the 
# structureby pfrag.
#
# Usage:
# source stride_by_pfrag.tcl 
#
#
# CHANGE stride PATH
#
#
display update off

# For very large systems, coordinates need to be translated to fit the PDB format.
proc moveby {sel offset} {
    foreach coord [$sel get {x y z}] {
        lappend newcoords [vecadd $coord $offset]
    }
    $sel set {x y z} $newcoords
}

# Select continuous protein fragments
set ptn [atomselect top "noh protein and backbone and pfrag >= 0" ]
set pfrag_list [lsort -unique -integer [$ptn get pfrag]]
set npfrag [ llength $pfrag_list ]

# Compute SS for each pfrag
foreach pf $pfrag_list {

  # Select current pfrag
  set ref [atomselect 0 "noh backbone and pfrag $pf"]
  set n [$ref num]

  # Create a temporary molecule and fill it with dummy atoms
  set tmpmolid [ mol new atoms $n]
  set atomslist [list]
  for {set i 1} {$i<=$n} {incr i} {
    ## list format {radius resname resid chain x y z occupancy element segname}
    lappend atomslist [list 0 DUM 9999 X 0.00 0.00 0.00 0 DUM MOLF]
  }

  # Initialize the dummy atoms pool
  set sel [atomselect $tmpmolid "all"]
  animate dup [molinfo top]

  # Replace dummy atoms by current pfrag
  $sel set {name type radius resname resid chain x y z occupancy element segname } [$ref get {name type radius resname resid chain x y z occupancy element segname}]

  # Translate coordinates to fit the PDB format.
  set vec [ vecscale -1 [measure center $sel]]
  moveby $sel $vec

  # Write temporary .PDB file for STRIDE
  $sel writepdb /tmp/pfrag_${pf}.pdb
  
  # Delete temporary molecule
  mol delete top

  # Compute SS using STRIDE
  set ssByRes {}
  # Run Stride
  set output [exec -ignorestderr /home/dgomes/software/stride/stride /tmp/pfrag_${pf}.pdb | grep ASG ]

  # Post-Process STRIDE output
  foreach line [split $output "\n"] {
    set wordList [regexp -inline -all -- {\S+} $line]
    lappend ssByRes [lindex $wordList 5]
  }

#  puts "$pf : $ssByRes"
  puts "$pf of $npfrag"

  # Select CA from current pfrag and assign SS
  set sel [atomselect 0 "pfrag $pf and name CA"]
  $sel set structure $ssByRes 

  # Delete temporary file.  
  file delete /tmp/pfrag_${pf}.pdb
}

display update on
quit
