# Useful VMD scripts

# Filter a trajectory
```tcl
# Load topology (PSF file)
mol load    psf system.1.0.psf

# Add a trajectory (DCD file)
mol addfile dcd system.1.3.dcd

# Create a selection
set sel [atomselect 0 "segid REC LIG"] 

# Write a new topology containing only my selection
$sel writepsf protein.psf

# Write a new trajectory containin only my selection
animate write dcd teste.dcd sel $sel

quit
```
