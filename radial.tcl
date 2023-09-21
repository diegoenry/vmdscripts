# Config
set distance_to_move 5.0 
set move_selection "[atomselect top "water"]"

# Step 1 - Get the box center
set center [measure center [ atomselect top all ] ]

# Step 2 - Select the group you'd like to move
set sel $move_selection 

# Loop over selected coordinates.
set newcoords {}
foreach coord [$sel get {x y z}] {
   
   # Compute the X,Y,Z distances to center.
   set delta [vecsub $coord $center]
   
   # Create new coordinates by moving by "distance_to_move".
   set ncoord [vecadd $coord [ vecscale ${distance_to_move} [vecnorm $delta]] ]
   lappend newcoords $ncoord
   
   if {0} {
     # Get cartesian distance to center.
     set d  [vecdist $coord  $center]
     set nd [vecdist $ncoord $center ]
     puts "Pref: [ format %.2f $d ] [ format %.2f $nd] [format %.2f [expr $nd - $d]] "
   }
}
$sel set {x y z} $newcoords


