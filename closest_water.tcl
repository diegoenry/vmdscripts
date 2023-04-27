#
# Read a .PSF/.DCD and write protein & N-closest water molecules
#

package require pbctools
#########################################
# Step 1 - Load Trajectory and PBC wrap
#########################################
set pbc_start [clock clicks -milliseconds]

mol new test.psf
mol addfile test.dcd first 1 last 50 waitfor all

# Get numframes
set numframes [molinfo top get numframes]

# Go to 1st frame and wrap all
animate goto 0
pbc wrap -centersel protein -center com -all

set pbc_time [expr [clock clicks -milliseconds] - $pbc_start]

################################################
# Step 2 - Store index and save .PSF for protein
#          and first 2k water molecules
################################################
set index_start [clock clicks -milliseconds]

set mylist [[atomselect top protein] get index]
set wfirst  [ lrange [ [atomselect top water] get index ] 0 5999 ]
lappend mylist {*}$wfirst

# Write a new topogy
[atomselect top "index $mylist"] writepsf closest.psf

# Load new topology
mol new closest.psf
set index_time [expr [clock clicks -milliseconds] - $index_start] 

################################################
# Step 3 - Loop over frames
################################################
set loop_start [clock clicks -milliseconds]

for {set i 0} {$i < $numframes} {incr i} {

  puts "Frame $i"
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
  set contact_start [clock clicks -milliseconds]

  # Protein close to waters
  set ptn [atomselect top "noh protein within 7 of water"]

  # Water close to protein
  set wat [atomselect top "noh water within 7 of protein"]


  # Get contacts
  set contacts [measure contacts 7 $ptn $wat]
  lappend contact_time [expr [clock clicks -milliseconds] - $contact_start]

  ################################################
  # Step 3.2 - Compute contact-pair distances
  ################################################
  set distance_start [clock clicks -milliseconds]

  # Set the pair lists
  set plist [lindex $contacts 0]
  set wlist [lindex $contacts 1]

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
  lappend distance_time [expr [clock clicks -milliseconds] - $distance_start]

  ################################################
  # Step 3.3 - Sort contacts by distance
  #            Pick closest 2k
  ################################################
  set sort_start [clock clicks -milliseconds]
  # Sort distance (ascending)
  set wlist_sorted [lsort -index 1 -decreasing $wlist]

  # Get a unique list from sorted.
  # it keeps the 1st match, which is lowest distance.
  set wlist_unique [lsort -unique -index 0 $wlist_sorted]

  # Sort again by index
  set wlist_resorted [lsort -index 0 $wlist_unique]

  set top [lrange $wlist_resorted 1 2000]

  set wclosest [lmap x $top {lindex $x 0}]

  lappend sort_time [expr [clock clicks -milliseconds] - $sort_start]

  ################################################
  # Step 3.4 - Get atom index for top 2k contacts
  #            Store their xyz to "coordbuf"
  ################################################
  set store_start [clock clicks -milliseconds]

  # Get indexes of atoms in that water molecule's residue
  set closest {}
  # Get resid
  set wres [ [atomselect top "index $wclosest"] get residue ] 
  # Get atom indexes
  set closest [ [atomselect top "residue $wres"] get index ]

  # Select closest waters.
  set writesel [atomselect top "index $closest"]

  # Store coordinates of selected water molecules
  set coordbuf [$writesel get {x y z}]
  $writesel delete

  lappend store_time [expr [clock clicks -milliseconds] - $store_start]

  ################################################
  # Step 3.5 - Create a frame
  #            write protein xyz
  #            write water xyz from "coordbuf"
  ################################################
  set frame_start [clock clicks -milliseconds]
  # Create a frame for mol 1
  mol top 1
  animate dup 1

  # Modify coordinates of the protein and first 2000 water molecules
  [ atomselect 1 protein ] set {x y z} [ [ atomselect 0 protein ] get {x y z} ]
  [ atomselect 1 water ]   set {x y z} $coordbuf

  # Cleanup atomselections
  foreach a [atomselect list] {$a delete}

  # Delete frame to start over
#  animate delete beg 0 end 1 skip 0 0
  lappend frame_time [expr [clock clicks -milliseconds] - $frame_start]

}
set loop_time [expr [clock clicks -milliseconds] - $loop_start]

################################################
# Step 4 - Set mol 1 as top
#          Write trajectory to .dcd
################################################
set write_start [clock clicks -milliseconds]
mol top 1
animate write dcd closest.dcd waitfor all
lappend write_time [expr [clock clicks -milliseconds] - $write_start]



# Step 5 - Timmings
proc average {list} {
  return [expr {[tcl::mathop::+ {*}$list 0.0] / max(1, [llength $list])}]
}
puts "
#########################################
# Step 1 - Load Trajectory and PBC wrap
# Step 2 - Store index and save .PSF for protein and first 2k water molecules
# Step 3 - Loop over frames
# Step 3.1 - Select interface atoms compute contacts
# Step 3.2 - Compute contact-pair distances
# Step 3.3 - Sort contacts by distance, pick closest 2k
# Step 3.4 - Get atom index for top 2k contacts, Store their xyz to coordbuf
# Step 3.5 - Create a frame, write protein xyz, write water xyz from coordbuf
# Step 4 - Set mol 1 as top - Write trajectory to .dcd
################################################
 Step 1   : $pbc_time
 Step 2   : $index_time
 Step 3   : [ expr $loop_time / 50 ] (avg/cycle)
 Step 3.1 : [ average $contact_time ]
 Step 3.2 : [ average $distance_time ] 
 Step 3.3 : [ average $sort_time ]
 Step 3.4 : [ average $store_time ]
 Step 3.5 : [ average $frame_time ]
 Step 4   : $write_time 
"

quit
