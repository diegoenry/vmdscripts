# Delete all graphics.
draw delete all

# Change graphics color to RED.
draw color 1 

# Define the three points that form the plane
set p1 [ lindex [ [atomselect top "index 8"]  get { x y z } ] 0 ]
set p2 [ lindex [ [atomselect top "index 9"]  get { x y z } ] 0 ]
set p3 [ lindex [ [atomselect top "index 10"] get { x y z } ] 0 ]

# Draw a triangle to show the plane.
draw triangle $p1 $p2 $p3

# Define the vector.
set p4 [ lindex [ [atomselect top "index 0"] get { x y z } ] 0 ]
set p5 [ lindex [ [atomselect top "index 2"] get { x y z } ] 0 ]
set vector [ vecsub $p4 $p5 ]

# Draw a cylinder to show the vector.
draw cylinder $p4 $p5 radius 0.2 

# Calculate two vectors in the plane.
set v1 [ vecsub $p1 $p2 ]
set v2 [ vecsub $p1 $p3 ]
 
# Calculate the normal vector of the plane using the cross product.
set normal [ veccross $v1 $v2 ] 

# Calculate the dot product between the vector and the normal vector.
set dot_product [ vecdot $vector $normal ]  

# Calculate the magnitudes of the vector, and for the normal vector of the plane.
set magnitude_vector [ veclength $vector ]
set magnitude_normal [ veclength $normal ]

# Calculate the angle between the vector and the normal of the plane.
set angle_rad [expr {acos($dot_product / ($magnitude_vector * $magnitude_normal))}]

# Convert to radians to degrees
set angle_deg [expr $angle_rad * (180.0/($M_PI)) ]

# Measure the angle to the plane.
set angle_to_plane [expr abs([ expr 90 - $angle_deg ])]

# Print the result.
puts "Angle: [ format %.2f $angle_to_plane ] "

