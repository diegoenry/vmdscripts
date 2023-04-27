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
    graphics $mol cylinder $start $middle radius 1.0 	 
    graphics $mol cone $middle $end radius 1.5 	 
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
  draw color red

  set selpulling [atomselect top "name CA and segname LIG and resid 22" frame $vmd_frame([molinfo top]) ]
  
  lassign [$selpulling get "x y z"] start

  set end [vecadd {0 0 5} $start]

  vmd_draw_arrow 0 $start $end
}

puts "Toaki"
#set smd [read_SMD "run.1/system.1.3.out" 100]
#puts [llength $smd]

