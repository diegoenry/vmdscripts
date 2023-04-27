# Functions
proc sasa_by_residue {} {
  # Create a selection for all protein atoms
  set all [atomselect top "protein"]

  # Get unique residue numbers
  set res_list [lsort -unique -integer [$all get residue]]

  # Loop over all residues
  foreach res $res_list { 

    # Create selection for current residue
    set sel [atomselect top "residue $res"] 

    # Measure sasa for current residue
    set res_sasa [measure sasa 1.4 $all -restrict $sel]

    # Save  
    $sel set user $res_sasa 
    puts "${res},[format {%0.3f} ${res_sasa}]" 

    # clean up inner loop
    $sel delete
  }

# Clean up
$all delete
unset res_list

}

# Compute sasa by residue
sasa_by_residue

# Color by SASA
mol modcolor  0 [molinfo top] User
mol colupdate 0 [molinfo top] 1
mol scaleminmax [molinfo top] 0 auto

