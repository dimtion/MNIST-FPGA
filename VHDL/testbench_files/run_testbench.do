# Compile Package(s)
vcom -93 -explicit -work work ../utils_pkg.vhd

# Compile Generic components
vcom -93 -explicit -work work ../DualPort_RAM.vhd
vcom -93 -explicit -work work ../SinglePort_RAM.vhd
vcom -93 -explicit -work work ../generic_LUT_unit.vhd

# Compile FCNN units
vcom -93 -explicit -work work ../FCNN_top_unit.vhd
# TBC...

# Compile Testbench
vcom -93 -explicit -work work ../testbench_MNIST_FCNN.vhd

# Launch simulation without optimization
vsim -novopt work.testbench_MNIST_FCNN

# Load waveform (uncomment to load the wave you saved).
do wave.do 

# Run simulation
run 10 ms
