# use frame 0 for the reference
set sel "backbone chain A and resid 565 to 571"

set reference [atomselect 0 $sel]

# the frame being compared
set compare [atomselect 1 $sel]

# Select all atoms
set all [atomselect 1 all]

# compute the transformation
set trans_mat [measure fit $compare $reference]

# Move all atoms according to alignment
$all move $trans_mat

