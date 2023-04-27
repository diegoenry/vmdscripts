set sel [atomselect top "segname PROA PROD"] 
set A [atomselect top "segname PROA"] 
set B [atomselect top "segname PROD"] 
set n 500 
set contact  [ expr { ([measure sasa 1.4 $A -samples $n] + [measure sasa 1.4 $B -samples $n] - [measure sasa 1.4 $sel -samples $n]) * 0.5 } ]
puts $contact

