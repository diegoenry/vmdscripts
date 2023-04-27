# Enable tracing of FRAME
proc enabletrace {} {
global vmd_frame
trace variable vmd_frame([molinfo top]) w ssupdate
}

proc disabletrace {} {
global vmd_frame
trace vdelete vmd_frame([molinfo top]) w ssupdate
}


proc ssupdate {name element op} {
  global vmd_frame
  mol ssrecalc 0
}

