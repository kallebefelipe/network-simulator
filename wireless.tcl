# Define opcaes dos nós wireless
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
# set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ifq) CMUPriQueue ; 
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 10 ;# number of mobilenodes
set val(rp) DSR ;# routing protocol
set val(x) 500 ;# X dimension of topography
set val(y) 500 ;# Y dimension of topography
set val(stop) 100 ;# time of simulation end
set val(veloc) 5.0 ;# velocidade no
set val(experiment) 1; # number of experiment
global defaultRNG

#Read arguments
if {$argc >= 2} {
	set val(rp) [expr [lindex $argv 0]]
	set val(nn) [expr [lindex $argv 1]]
    set val(veloc) [expr [lindex $argv 2]]
    set val(experiment) [expr [lindex $argv 3]]
}

# seed the default RNG
$defaultRNG seed $val(experiment)
# create the RNGs and set them to the correct substream
set sizeRNG [new RNG]
$sizeRNG next-substream

# size_ is a uniform random variable describing packet sizes
set size_ [new RandomVariable/Uniform]
$size_ set min_ 1
$size_ set max_ 499
$size_ use-rng $sizeRNG

puts "$val(rp) $val(nn) $val(veloc) $val(experiment)"

# *** Packet Loss Trace ***
set f0 [open trace_files/$val(rp)_$val(nn)_$val(veloc).tr a+]

set nsim [new Simulator]

# Abre o arquivo de trace do nam
set nf [open wireless.nam w]
$nsim namtrace-all-wireless $nf $val(x) $val(y)

# Cria o arquivo de trace em formato geral
set tf [open wireless.tr w]
$nsim trace-all $tf

# Define um procedimento 'finish'
proc finish {} {
        global nsim nf tf
        $nsim flush-trace
	#Fecha o aquivo de trace
        close $nf
        close $tf
	#Executa o nam com o arquivo de trace
        #exec nam out.nam &
        exit 0
}

# Define objeto de topografia
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# Configura os nos
$nsim node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON

# Cria os nos
for {set i 0} {$i < $val(nn) } { incr i } {
    set n($i) [$nsim node]
}

for {set i 0} {$i < $val(nn) } { incr i } {
    set xx [expr round([$size_ value])]
    set yy [expr round([$size_ value])]
    
    $n($i) set X_ $xx
    $n($i) set Y_ $yy
    $n($i) set Z_ 0.0        
}

# Setup traffic flow between nodes
# UDP connections between node_(0) and node_(1)
# Create Constant four Bit Rate Traffic sources
for {set i 0} {$i < $val(nn) } { incr i } {
    puts "n($i+1)"
    set agent($i) [new Agent/UDP]             ;# Create UDP Agent
    set sink($i) [new Agent/LossMonitor]  ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
    $nsim attach-agent $n($i) $agent($i)     ;# Attach Agent to source node
    $nsim attach-agent $n([expr $i+1]) $sink($i) ;# Attach Agent to sink node
    $nsim connect $agent($i) $sink($i)            ;# Connect the nodes
    set app($i) [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
    $app($i) set packetSize_ 512               ;# Set Packet Size to 512 bytes
    $app($i) set rate_ 600Kb                    ;# Set CBR rate to 200 Kbits/sec
    $app($i) attach-agent $agent($i)             ;# Attach Application to agent
    $nsim at 50.4 "$app($i) start"
    set i [expr {$i + 1}]
}

# Define rotulos
# Cria os nos
for {set i 0} {$i < $val(nn) } { incr i } {
    $nsim at 0.0 "$n($i) label N$i"
}


# Define movimentacao dos nos
#Destination procedure..
$nsim at 0.0 "destination"
proc destination {} {
      global nsim val n size_
      set time 1.0
      set now [$nsim now]
      for {set i 0} {$i<$val(nn)} {incr i} {
            set xx [expr round([$size_ value])]
            set yy [expr round([$size_ value])]
            $nsim at $now "$n($i) setdest $xx $yy $val(veloc)"
      }
      $nsim at [expr $now+$time] "destination"
}

# Initialize Flags
set holdtime 0

# Function To record Statistcis (Bit Rate, Delay, Drop)

$nsim at 100 "record"
proc record {} {
    global sink f0 holdtime val n experiment
    set ns [Simulator instance]

    set time 0 ;#Set Sampling Time to 0.9 Sec 

    set pkts_receive 0 
    set pkts_lost 0

    for {set i 0} {$i < $val(nn) } { incr i } {
        set pkts_receive [expr {$pkts_receive + [$sink($i) set npkts_]}]
        set pkts_lost [expr {$pkts_lost + [$sink($i) set nlost_]}]

        set i [expr {$i + 1}]
    }

    set now [$ns now]
    puts $f0 "Experimento $val(experiment) PDR: [expr  [format %.2f $pkts_receive]/($pkts_receive+$pkts_lost)]"
    
    # Reset Variables
    $sink(2) set bytes_ 0

    $ns at [expr $now+$time] "record"  ;# Schedule Record after $time interval sec
    
}

proc stop {} {
    global nsim f0

    # Close Trace Files
    close $f0

    # Reset Trace File
    $nsim flush-trace
    close $tracefd
    exit 0
}

# Reseta os nos
for {set i 0} {$i < $val(nn) } { incr i } {
$nsim at $val(stop) "$n($i) reset";
}

$nsim at $val(stop) "$nsim nam-end-wireless $val(stop)"
$nsim at $val(stop) "finish"
$nsim at 100 "puts \"end simulation\" ; $nsim halt"

# Stop Simulation at Time val(stop) sec
$nsim at $val(stop) "stop"

$nsim run
