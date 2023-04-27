proc renumber {start molid} {
  
  set old   [ $sel get resid ]
  set delta [ expr $start - [ lindex $old 0] ]

  set new {}

  foreach r $old {
    lappend new [ expr $r + $delta ]
  }

  $sel set resid $new
}

mol new mol1.pdb

mol new mol2.pdb
renumber 569 1

mol new mol3.pdb

