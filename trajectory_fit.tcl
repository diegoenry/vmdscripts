proc rmsd {{mol top} {sel "protein"} } {

  # use frame 0 for the reference
  set reference [atomselect $mol $sel frame 0]

  # the frame being compared
  set compare [atomselect $mol $sel]

  # Select all atoms
  set all [atomselect top all]

  # Set the numver of available frames
  set num_steps [molinfo $mol get numframes]

  for {set frame 0} {$frame < $num_steps} {incr frame} {

    # get the correct frame
    $compare frame $frame

    # compute the transformation
    set trans_mat [measure fit $compare $reference]

    # Move all atoms according to alignment
    $all      frame $frame
    $all move $trans_mat

    # compute the RMSD
#    set rmsd [measure rmsd $compare $reference]
    # print the RMSD
#    puts "RMSD of $frame is $rmsd"
    }
}

