proc affibody {} {
mol modselect 0 0 segid REC
mol modstyle 0 0 NewCartoon 0.300000 10.000000 4.100000 0

mol addrep 0
mol modselect 1 0 segid LIG
mol modstyle 1 0 NewCartoon 0.300000 10.000000 4.100000 0

mol modcolor 0 0 Structure
mol modcolor 1 0 Structure

mol addrep 0
mol modselect 2 0 protein noh same residue as within 5 of segid REC and within 5 of segid LIG
mol modstyle 2 0 Licorice 0.200000 12.000000 12.000000
mol modcolor 2 0 Type
color Type C white

mol smoothrep 0 0 5
mol smoothrep 0 1 5
mol smoothrep 0 2 5

mol modmaterial 0 0 AOEdgy
mol modmaterial 1 0 AOEdgy
mol modmaterial 2 0 AOEdgy

mol color ColorID 16
mol representation VDW 1.000000 12.000000
mol selection name CA and segid REC and resid 215
mol material AOEdgy
mol addrep 0

#mol addrep 0
#mol modselect 3 0 name CA and (segid REC and resid 215 or segid LIG and resid 22)
#mol modcolor 3 0 ColorID 1
#mol modstyle 3 0 VDW 1.000000 12.000000
#mol modmaterial 3 0 AOEdgy

color Display Background white
display shadows on
display ambientocclusion on
display resetview
}

proc affibody_pulling_points {} {
mol color ColorID 1
mol representation VDW 0.600000 12.000000
mol selection name CA and segid LIG and resid 1
mol material AOEdgy
mol addrep 0

mol color ColorID 7
mol representation VDW 0.600000 12.000000
mol selection name CA and segid LIG and resid 22
mol material AOEdgy
mol addrep 0

mol color ColorID 25
mol representation VDW 0.600000 12.000000
mol selection name CA and segid LIG and resid 40
mol material AOEdgy
mol addrep 0

mol color ColorID 4
mol representation VDW 0.600000 12.000000
mol selection name CA and segid LIG and resid 47
mol material AOEdgy
mol addrep 0

mol color ColorID 0
mol representation VDW 0.600000 12.000000
mol selection name CA and segid LIG and resid 60
mol material AOEdgy
mol addrep 0

}

proc affibody_fit {{mol top} {sel "noh (segname REC and resid 1 to 115 or segname LIG and resid 1 to 60)"} } {
  
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

proc affibody_draw_arrows {} {

draw delete all

set color_dict [dict create M1 red N22 green S40 violet S47 yellow G60 blue]
set resid_dict [dict create M1 1   N22 22    S40 40     S47 47     G60 60]

foreach res [list M1 N22 S40 S47 G60] {
    draw color [dict get $color_dict $res]
    set resid  [dict get ${resid_dict} $res]
    set sel [atomselect top "name CA and segname LIG and resid ${resid}" ]
    lassign [$sel get "x y z"] start
    set end [vecadd {0 0 10} $start]
    vmd_draw_arrow 0 $start $end
}
}
