# Usage: ns rng-test.tcl [replication number]

set run 1

# seed the default RNG
global defaultRNG
$defaultRNG seed 3

# create the RNGs and set them to the correct substream
set sizeRNG [new RNG]
for {set j 1} {$j < $run} {incr j} {
    $sizeRNG next-substream
}


# size_ is a uniform random variable describing packet sizes
set size_ [new RandomVariable/Uniform]
$size_ set min_ 0
$size_ set max_ 500
$size_ use-rng $sizeRNG

# print the first 5 arrival times and sizes
for {set j 0} {$j < 5} {incr j} {
    puts [format " %-4d" [expr round([$size_ value])]]
    puts [format " %-4d" [expr round([$size_ value])]]
}