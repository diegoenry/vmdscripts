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
set ptn [atomselect top "protein and pfrag >= 0" ]
set pfrag_list [lsort -unique -integer [$ptn get pfrag]]
set npfrag [ llength $pfrag_list ]

# Compute SS for each pfrag
foreach pf $pfrag_list {

  # Select current pfrag
  set ref [atomselect 0 "pfrag $pf and backbone"]
#  set n [$ref num]

  puts "$pf of $npfrag"
}
display update on
quit
