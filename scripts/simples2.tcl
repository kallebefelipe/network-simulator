# Cria o objeto simulador (escalonador de eventos)
set nsim [new Simulator]

# Abre o arquivo de trace do nam
set nf [open simples2.nam w]
$nsim namtrace-all $nf

# Define um procedimento 'finish'
proc finish {} {
        global nsim nf
        $nsim flush-trace
	#Fecha o aquivo de trace
        close $nf
	#Executa o nam com o arquivo de trace
        exec nam simples2.nam &
        exit 0
}

# Cria dois n�s
set n0 [$nsim node]
set n1 [$nsim node]

# Cria link duplex entre os n�s
$nsim duplex-link $n0 $n1 1Mb 10ms DropTail

# Cria e anexa um agent transmissor
set udp0 [new Agent/UDP]
$nsim attach-agent $n0 $udp0

# Cria uma aplica��o
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packet_size_ 500
$cbr0 set rate_ 800Kb
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$nsim attach-agent $n1 $null0

$nsim connect $udp0 $null0

# Inicializa e para a aplica��o
$nsim at 0.5 "$cbr0 start"
$nsim at 4.5 "$cbr0 stop"

# Chama o procedimento finish ap�s 5 segundos na linha de tempo da simula��o
$nsim at 5.0 "finish"

# Executa a simula��o
$nsim run

