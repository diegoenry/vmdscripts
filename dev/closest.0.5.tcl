package require pbctools

#########################################
# Step 1 - Load Trajectory and PBC wrap
#########################################
mol new test.psf
mol addfile test.dcd first 1 last 50 waitfor all

# Get numframes
set numframes [molinfo top get numframes]

# Go to 1st frame and wrap all
animate goto 0
pbc wrap -centersel protein -center com -all

################################################
# Step 2 - Store index and save .PSF for protein
#          and first 2k water molecules
################################################
set mylist [[atomselect top protein] get index]
set wfirst  [ lrange [ [atomselect top water] get index ] 0 5999 ]
lappend mylist {*}$wfirst

# Write a new topogy
[atomselect top "index $mylist"] writepsf closest.psf

# Load new topology
mol new closest.psf

################################################
# Step 3 - Loop over frames
################################################
for {set i 0} {$i < $numframes} {incr i} {

  # Work with mol 0
  mol top 0

  # Go to frame
  animate goto $i

  # Wrap
  # animate read dcd test.dcd beg $i end $i waitfor all
  # pbc wrap -centersel protein -center com

  ################################################
  # Step 3.1 - Select interface atoms
  #            & compute contacts
  ################################################
  # Protein close to waters
  set ptn [atomselect top "noh protein within 7 of water"]

  # Water close to protein
  set wat [atomselect top "noh water within 7 of protein"]

  # Get contacts
  set contacts [measure contacts 7 $ptn $wat]
  $ptn delete
  $wat delete

  ################################################
  # Step 3.2 - Compute contact-pair distances
  ################################################
  # Set the pair lists
  set plist [lindex $contacts 0]
  set wlist [lindex $contacts 1]
  unset contacts

  # Loop over pairs to compute distance
  for {set j 0} { $j < [llength $plist]} {incr j} {

    # Get atom index
    set patom [lindex $plist $j]
    set watom [lindex $wlist $j]

    # Measure distance
    set d [measure bond "$patom $watom"]

    # Replace values in wlist, now to contain watom and distance
    lset wlist $j [list $watom $d]
  }
  unset plist

  ################################################
  # Step 3.3 - Sort contacts by distance
  #            Pick closest 2k
  ################################################
  # Sort distance (ascending)
  set wlist_sorted [lsort -index 1 -decreasing $wlist]
  unset wlist

  # Get a unique list from sorted.
  # it keeps the 1st match, which is lowest distance.
  set wlist_unique [lsort -unique -index 0 $wlist_sorted]
  unset wlist_sorted

  # Sort again by index
  set wlist_resorted [lsort -index 0 $wlist_unique]
  unset wlist_unique

  set top [lrange $wlist_resorted 1 2000]
  unset wlist_resorted

  set wclosest [lmap x $top {lindex $x 0}]
  unset top

  ################################################
  # Step 3.4 - Get atom index for top 2k contacts
  #            Store their xyz to "coordbuf"
  ################################################
  # Get indexes of atoms in that water molecule's residue
  set closest {}
  foreach ndx $wclosest {
    # Get resid
    set wres [ [atomselect top "index $ndx"] get residue ]
    append closest " " [ [atomselect top "residue $wres"] get index ]
  }
  unset wres
  unset wclosest

  # Select closest waters.
  set writesel [atomselect top "index $closest"]
  unset closest

  # Store coordinates of selected water molecules
  set coordbuf [$writesel get {x y z}]
  $writesel delete

  ################################################
  # Step 3.5 - Create a frame
  #            write protein xyz
  #            write water xyz from "coordbuf"
  ################################################
  # Create a frame for mol 1
  mol top 1
  animate dup 1

  # Modify coordinates of the protein and first 2000 water molecules
  [ atomselect 1 protein ] set {x y z} [ [ atomselect 0 protein ] get {x y z} ]
  [ atomselect 1 water ]   set {x y z} $coordbuf

  unset coordbuf

  # Delete frame to start over
#  animate delete beg 0 end 1 skip 0 0

}

################################################
# Step 4 - Set mol 1 as top
#          Write trajectory to .dcd
################################################
mol top 1
animate write dcd closest.dcd waitfor all

quit
