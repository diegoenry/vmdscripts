package provide QwikReplicas 0.1


namespace eval ::QWIKREPLICA:: {

    namespace export qwikreplica

# 	Window handles
    variable main_win      			;	# handle to main window
    variable replica                ; 
    variable replica_list           ; 
    variable sel1 "segid REC and resid 1 to 115"
    variable sel2 "segid LIG"
    variable cutoff 3.6
    variable contact_list
    variable frame 0
    variable numframes 0
    variable smd_force
}

proc list_replicas {} {
    # List replicas
    set tmp [glob -tails -directory replicas -type d run.*]

    set runlist {}

    foreach run $tmp { lappend runlist [ lindex [split $run .] 1 ] }

    set ::QWIKREPLICA::replica_list [ lsort -integer $runlist ]
}

proc affibody {} {
mol modselect 0 top segid REC
mol modstyle 0 top NewCartoon 0.300000 10.000000 4.100000 0

mol addrep top
mol modselect 1 top segid LIG
mol modstyle 1 top NewCartoon 0.300000 10.000000 4.100000 0

mol modcolor 0 top Structure
mol modcolor 1 top Structure
display resetview

mol smoothrep top 0 5
mol smoothrep top 1 5

mol addrep top
mol modselect 2 top noh same residue as within 5 of segid REC and within 5 of segid LIG
mol smoothrep top 2 5
mol modstyle 2 top Licorice 0.200000 12.000000 12.000000
mol modcolor 2 top Type
color Type C white
}

proc load_replica {} {
    # Cleanup

    if { [molinfo list] > -1 } {
        foreach item [molinfo list] { mol delete $item }
    }
    
    mol new setup/complex.psf
    mol addfile trajectories/run.$::QWIKREPLICA::replica.dcd waitfor all
    mol rename top "run.$::QWIKREPLICA::replica"
    animate goto 0 

    affibody
}


proc measure_contacts {} {
    
    set sel1 [ atomselect top "noh $::QWIKREPLICA::sel1" ] 
    set sel2 [ atomselect top "noh $::QWIKREPLICA::sel2" ]

    set ::QWIKREPLICA::numframes [molinfo top get numframes]

    set ::QWIKREPLICA::contact_list {}
    
    display update off 

    for { set frame 0 } { $frame < $::QWIKREPLICA::numframes } { incr frame } {
        animate goto ${frame}
        set contacts [measure contacts $::QWIKREPLICA::cutoff $sel1 $sel2]
        set ncontacts [llength [lindex $contacts 0]]
        #puts -nonewline "${ncontacts} "
        lappend ::QWIKREPLICA::contact_list ${ncontacts}
    }
    puts "\[ DONE \]"

    display update on
}

proc read_SMD {} {
    set myFile "replicas/run.${::QWIKREPLICA::replica}/system.1.3.out"
    puts "Reading $myFile"

    # Read all contents
    set fp [open ${myFile} r]
    set data [split [read ${fp}] "\n"]
    close ${fp}

    set smd {}
    foreach line ${data} {
        if [ regexp "^SMD " "${line}" f ] {  
            lappend smd [ lindex [ split $line ] 8 ]
        }

    }

    puts "Done reading $myFile"
    
    # Skip some steps to match trajectory
    set skip 50
    set ::QWIKREPLICA::smd_force {}
    set counter 0
    foreach force $smd {
        if { ${counter} == $skip } {
            lappend ::QWIKREPLICA::smd_force $force
            set counter 0
        } 
        incr counter 1 
    }
    #set ::QWIKREPLICA::smd_force $smd
}


proc QWIKREPLICA::qwikreplica {} {
    global env
	variable main_win 

	# Main window
	set           main_win [ toplevel .qwikreplica ]
	wm title     $main_win "Replica Explorer 0.1" 
	wm resizable $main_win 0 0     ; #Not resizable

	if {[winfo exists $main_win] != 1} {
			raise $main_win

	} else {
			wm deiconify $main_win
	}

     
    # List replicas
    list_replicas

    ########################################################################
    # LabelFrame picking replica
    ########################################################################
    grid [ ttk::labelframe $main_win.choice -text "Choose replica" -relief groove  ] \
        -row 0 -padx 5 -pady 5 -sticky news 
              
        grid [ ttk::combobox $main_win.choice.combobox -textvariable ::QWIKREPLICA::replica -values $::QWIKREPLICA::replica_list ] \
            -row 0 -column 0 -padx 5 -pady 5 -sticky news 
        
        grid [ttk::button $main_win.choice.button -text "Load" -command { load_replica } ] \
            -row 0 -column 1 -padx 5 -pady 5 -sticky nsew

    grid [ ttk::labelframe $main_win.force -text "SMD forces" -relief groove  ] \
        -row 0 -column 1 -padx 5 -pady 5 -sticky news 

        grid [ttk::button $main_win.force.read -text "Read" -command { read_SMD } ] \
            -row 0 -column 0 -padx 5 -pady 5 -sticky nsew

        grid [ttk::button $main_win.force.plot -text "Plot" -command { 
            set plothandle [multiplot -y $::QWIKREPLICA::smd_force -title "Contacts" -lines -plot] } ] \
            -row 0 -column 1 -padx 5 -pady 5 -sticky nsew
        
    grid [ ttk::labelframe $main_win.contacts -text "Measure contacts" -relief groove  ] \
        -row 1 -columnspan 2 -padx 5 -pady 5 -sticky news

        grid [ttk::label $main_win.contacts.sel1_label -text "Selection 1" ] \
            -column 0 -row 0

        grid [ttk::entry $main_win.contacts.sel1_entry -width 50 -textvariable ::QWIKREPLICA::sel1 ] \
            -column 1 -columnspan 3 -row 0 -padx 5 -pady 5 -sticky nsew

        grid [ttk::label $main_win.contacts.sel2_label -text "Selection 2" ] \
            -column 0 -row 1

        grid [ttk::entry $main_win.contacts.sel2_entry -width 50 -textvariable ::QWIKREPLICA::sel2 ] \
            -column 1 -columnspan 3 -row 1 -padx 5 -pady 5 -sticky nsew

        grid [ttk::label $main_win.contacts.cutoff -text "Cutoff" ] \
            -column 0 -row 2 -padx 5 -pady 5 -sticky nsew
        
        grid  [spinbox $main_win.contacts.spinbox -from 1.5 -to 7.0 -increment 0.5 -justify right -textvariable cutoff -value $::QWIKREPLICA::cutoff ] \
            -column 1 -row 2 -padx 5 -pady 5 -sticky nsew

        grid [ttk::button $main_win.contacts.run -text "Run" -command { measure_contacts } ] \
            -row 2 -column 2 -padx 5 -pady 5 -sticky nsew

        grid [ttk::button $main_win.contacts.plot -text "Plot" -command { 
            # Multiplot NEEDS floating point numbers on the Y axis !
            set ys {} ; foreach num $::QWIKREPLICA::contact_list { lappend ys [expr double($num)] }
            #if [info exists plothandle ] { $plothandle close }
            set plothandle [multiplot -y $ys -title "Contacts" -lines -plot] } ] \
            -row 2 -column 3 -padx 5 -pady 5 -sticky nsew


}

proc qwikreplica {} { return [eval QWIKREPLICA::qwikreplica]}
QWIKREPLICA::qwikreplica