proc vmd_draw_arrow {mol start end} { 	 
    set middle [vecadd $start [vecscale 0.8 [vecsub $end $start]]]
    graphics $mol cylinder $start $middle radius 1.0
    graphics $mol cone $middle $end radius 2.5
}

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

