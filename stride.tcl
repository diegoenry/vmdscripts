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
#       $RCSfile: stride.tcl,v $
#       $Author: dgomes $        $Locker:  $             $State: Exp $
#       $Revision: 0.1 $         $Date: 2023/08/28 09:15:56 $
#
############################################################################
#
# VMD stride by pfrag $Revision: 0.1 $
#
#
# Script to compute the secondary structure using STRIDE,
#
# Usage:
# source stride.tcl 
#
# Known limitations:
#   To account for altloc, this script requires the occupancy fields.
#
#
# CHANGE stride PATH
#
#

# Select protein, without Hydrogens and write a temporary PDB file
set ptn [atomselect top "noh protein"]
$ptn writepdb /tmp/ptn.pdb

# Compute SS using STRIDE
set ssByRes {}
set output [exec /home/dgomes/software/stride/stride /tmp/ptn.pdb | grep ASG ]
#set output [exec /cm/shared/apps/vmd/lib/vmd/stride_LINUXAMD64 /tmp/ptn.pdb | grep ASG ]

# Post-Process STRIDE output
foreach line [split $output "\n"] {
  set wordList [regexp -inline -all -- {\S+} $line]
  lappend ssByRes [lindex $wordList 5]
}

#puts $ssByRes

set i 0
set pfrag_list [lsort -unique -integer [$ptn get pfrag]]
foreach pf $pfrag_list {
  # Select CA from current pfrag and assign SS
  set sel [atomselect top "pfrag $pf and name CA and occupancy > 0.5"]
  set mlength [expr [$sel num] - 1]
  puts "$pf $i $mlength"
  $sel set structure [lrange $ssByRes $i [expr $i + $mlength ] ] 
    incr i $mlength
}

# Delete temporary PDB file.
file delete /tmp/ptn.pdb

