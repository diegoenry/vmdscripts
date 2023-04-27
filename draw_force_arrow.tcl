# Enable tracing of FRAME
proc enabletrace {} { 	 
global vmd_frame 	 
trace variable vmd_frame([molinfo top]) w drawcounter 	 
} 	 

proc disabletrace {} { 	 
global vmd_frame 	 
trace vdelete vmd_frame([molinfo top]) w drawcounter 	 
}


proc vmd_draw_arrow {mol start end} { 	 
    set middle [vecadd $start [vecscale 0.8 [vecsub $end $start]]] 	 
    graphics $mol color red
    graphics $mol cylinder $start $middle radius 0.5	 
    graphics $mol cone $middle $end radius 1.0 	 
}


proc read_SMD {myFile {skip 1}} {
    set force {}
    set data [split [exec grep "^SMD " $myFile] "\n"]

    set counter 1
    foreach line ${data} {
        if { $counter == $skip } {
            set counter 1
            lappend force [ lindex [ split $line ] 8 ]
        }
        incr counter 1
    }
    return $force
}


# Select pull point
proc drawcounter {name element op} {
  global vmd_frame
  
  draw delete all

  set selpulling [atomselect top "chain C and name CA and resid 14" frame $vmd_frame([molinfo top]) ]
  
  lassign [$selpulling get "x y z"] start

  set end [vecadd {0 0 10} $start]

  vmd_draw_arrow 0 $start $end

  mol ssrecalc 0
}

puts "Toaki"
#set smd [read_SMD "run.1/system.1.3.out" 100]
#puts [llength $smd]

