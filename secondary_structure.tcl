# Compute secondary structure for file/trajectory
# Outputs to stdout
set numframes [ molinfo top get numframes ] 

set sel [atomselect top "name CA"]

for {set i 0} {${i} <= ${numframes} } {incr i} {

  animate goto ${i}
  mol ssrecalc top
  $sel frame ${i}
  set structure [$sel get structure]
  puts $structure


}
