# Basically I rewrote PyContact in .TCL

# Create peak trajectories folder. (output)
if {! [file isdirectory analysis]} {
  file mkdir analysis
}
# Set and open output file
set contacts [open [file join analysis contacts.dat]      w]
set pair_contacts [open [file join analysis pair_contacts.dat]      w]


# Set cutoff
set cutoff 4.0

mol new protein.psf
mol addfile protein.pdb

# Get list of residues (use 'residue' and not 'resid' so we don't get 
# duplicate residues from unusual PDB files..)  
set rec [atomselect top "segname REC"] 
set rec_res_list [lsort -unique [$rec get residue]]

set lig [atomselect top "segname LIG"] 
set lig_res_list [lsort -unique [$lig get residue]]

puts ${contacts} "c_rec_lig c_rec_h1 c_rec_h2 c_rec_h3 c_h1_h2 c_h2_h3 c_h2_h3"

for {set run 1} {$run < 49} {incr run 1} {

	puts "Run: ${run}"

	animate delete all 

	mol addfile trajectories/run.${run}.dcd waitfor all

	set numframes [ molinfo top get numframes ] 

	for {set i 0} {${i} <= ${numframes} } {incr i} {
		
#		# Ligand and helices
		set rec [atomselect top "noh segname REC" frame ${i}]
		set lig [atomselect top "noh segname LIG" frame ${i}]
		set h1  [atomselect top "noh segname LIG and resid 1 to 22"  frame ${i}]
		set h2  [atomselect top "noh segname LIG and resid 23 to 40" frame ${i}]
		set h3  [atomselect top "noh segname LIG and resid 41 to 60" frame ${i}]

		# Ligand and helices
#		set rec [atomselect top "segname REC" frame ${i}]
#		set lig [atomselect top "segname LIG" frame ${i}]
#		set h1  [atomselect top "segname LIG and resid 1 to 22"  frame ${i}]
#		set h2  [atomselect top "segname LIG and resid 23 to 40" frame ${i}]
#		set h3  [atomselect top "segname LIG and resid 41 to 60" frame ${i}]

		# Measure contacts
		set rec_lig [measure contacts ${cutoff} $rec $lig]
		set rec_h1  [measure contacts ${cutoff} $rec $h1]
		set rec_h2  [measure contacts ${cutoff} $rec $h2]
		set rec_h3  [measure contacts ${cutoff} $rec $h3]
		set h1_h2   [measure contacts ${cutoff} $h1  $h2]
		set h1_h3   [measure contacts ${cutoff} $h1  $h2]
		set h2_h3   [measure contacts ${cutoff} $h1  $h2]

		# Count number of contacts 
		set c_rec_lig [llength [lindex $rec_lig 0]]
		set c_rec_h1  [llength [lindex $rec_h1  0]]
		set c_rec_h2  [llength [lindex $rec_h2  0]]
		set c_rec_h3  [llength [lindex $rec_h3  0]]
		set c_h1_h2   [llength [lindex $h1_h2   0]] 
		set c_h2_h3   [llength [lindex $h1_h2   0]]
		set c_h2_h3   [llength [lindex $h1_h2   0]]


		puts ${contacts} "${run} ${i} ${c_rec_lig} ${c_rec_h1} ${c_rec_h2} ${c_rec_h3} ${c_h1_h2} ${c_h2_h3} ${c_h2_h3}"


		# Paired interactions by residue			
        #set pairs {}
        set prev_pair ""
        set npair_contacts 0

		for {set j 0} {$j < [llength [lindex $rec_lig 0 ]]} {incr j} {

		  set rec_idx [lindex [lindex $rec_lig 0] ${j} ]
		  set lig_idx [lindex [lindex $rec_lig 1] ${j} ]
		  
		  set rec_res [ [atomselect top "index ${rec_idx}"] get resid ]
		  set lig_res [ [atomselect top "index ${lig_idx}"] get resid ]
		  		  
		  if { $prev_pair == "${rec_res} ${lig_res}" } {
			  incr npair_contacts 1
			  set prev_pair "${rec_res} ${lig_res}"
			  
			  } else { 
				  if { ${j} != 0 } {  
				    lappend pairs "${prev_pair} ${npair_contacts}"
				  }
			      set npair_contacts 1
			      set prev_pair "${rec_res} ${lig_res}"
		  }  
#		  puts "${prev_pair} ${npair_contacts}"
		}	
		
# This is currently generating a huge file due to the amount of replicas.	  	  
		# Number of unique contacts per pair.
#		foreach line ${pairs} {
#			puts ${pair_contacts} "${run} ${i} ${line} "
#			}
	}
}
quit




