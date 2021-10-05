# Useful VMD scripts
VMD is an amazingly powerfull GUI for molecular modeling. It has is blazing fast I/O, and rendering capabilities.
Althoug it has plenty of plugins, they lack a commom framework. Currently, scripting is key to success.
Before tackling that, I will collect and review and document some usefull capabilites.

## Filter a trajectory
```tcl
# Load topology (PSF file)
mol load    psf system.1.0.psf

# Add a trajectory (DCD file)
mol addfile dcd system.1.3.dcd

# Create a selection
set sel [atomselect 0 "segid REC LIG"] 

# Write a new topology containing only my selection
$sel writepsf protein.psf

# Write a new trajectory containin only my selection
animate write dcd teste.dcd sel $sel

quit
```

## Fitting a trajectory
```tcl
proc rmsd {{mol top} {sel1 "protein"} } {

  # use frame 0 for the reference
  set reference [atomselect $mol $sel frame 0]

  # the frame being compared
  set compare [atomselect $mol $sel]

  # Set the numver of available frames
  set num_steps [molinfo $mol get numframes]

  for {set frame 0} {$frame < $num_steps} {incr frame} {

    # get the correct frame
    $compare frame $frame

    # compute the transformation
    set trans_mat [measure fit $compare $reference]

    # do the alignment
    #$compare move $trans_mat
    $all move $trans_mat

    # compute the RMSD
    set rmsd [measure rmsd $compare $reference]
    # print the RMSD
    puts "RMSD of $frame is $rmsd"
    }
}
```

From VMD user guide.
https://www.ks.uiuc.edu/Research/vmd/vmd-1.7.1/ug/node185.html
# Prints the RMSD of the protein atoms between each timestep
        # and the first timestep for the given molecule id (default: top)
        proc print_rmsd_through_time {{mol top}} {
                # use frame 0 for the reference
                set reference [atomselect $mol "protein" frame 0]
                # the frame being compared
                set compare [atomselect $mol "protein"]

                set num_steps [molinfo $mol get numframes]
                for {set frame 0} {$frame < $num_steps} {incr frame} {
                        # get the correct frame
                        $compare frame $frame

                        # compute the transformation
                        set trans_mat [measure fit $compare $reference]
                        # do the alignment
                        $compare move $trans_mat
                        # compute the RMSD
                        set rmsd [measure rmsd $compare $reference]
                        # print the RMSD
                        puts "RMSD of $frame is $rmsd"
                }
        }
