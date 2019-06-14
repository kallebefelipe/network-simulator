# Cria o objeto simulador (escalonador de eventos)
set nsim [new Simulator]

# Abre o arquivo de trace do nam
set nf [open saida.nam w]
$nsim namtrace-all $nf

# Define um procedimento 'finish'
proc finish {} {
        global nsim nf
        $nsim flush-trace
	#Fecha o aquivo de trace
        close $nf
	#Executa o nam com o arquivo de trace
        #exec nam out.nam &
        exit 0
}

# Cria dois nós
set n0 [$nsim node]
set n1 [$nsim node]

# Cria link duplex entre os nós
$nsim duplex-link $n0 $n1 1Mb 10ms DropTail

# Chama o procedimento finish após 5 segundos na linha de tempo da simulação
$nsim at 5.0 "finish"

# Executa a simulação
$nsim run

