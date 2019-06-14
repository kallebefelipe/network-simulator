# Cria o objeto simulador
set nsim [new Simulator]

# Abre o arquivo de trace do nam
set nf [open simples3.nam w]
$nsim namtrace-all $nf
# cria o arquivo de trace em formato geral
set tf [open simples3.tr w]
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

# Cria quatro nós
set n0 [$nsim node]
set n1 [$nsim node]
set n2 [$nsim node]
set n3 [$nsim node]

# Cria os links entre os nós
$nsim duplex-link $n0 $n2 2Mb 10ms DropTail
$nsim duplex-link $n1 $n2 2Mb 10ms DropTail
$nsim duplex-link $n2 $n3 1.7Mb 20ms DropTail

# Determina a posição dos nós/links no nam
#ns-nam
$nsim duplex-link-op $n0 $n2 orient right-down
$nsim duplex-link-op $n1 $n2 orient right-up
$nsim duplex-link-op $n2 $n3 orient right
# Determina a cor dos fluxos
$nsim color 1 Blue
$nsim color 2 Red

# Configurando as conexões:
# Configura conexão TCP
set tcp [new Agent/TCP]
$nsim attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$nsim attach-agent $n3 $sink
$nsim connect $tcp $sink
$tcp set fid_ 1

# Configura uma conexão FTP sobre TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

# Configura uma conexao UDP
set udp [new Agent/UDP]
$nsim attach-agent $n1 $udp
set null [new Agent/Null]
$nsim attach-agent $n3 $null
$nsim connect $udp $null
$udp set fid_ 2

# Configura um CBR sobre UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 1mb

# Agenda os eventos para os agentes CBR e FTP
$nsim at 0.1 "$cbr start"
$nsim at 1.0 "$ftp start"
$nsim at 4.0 "$ftp stop"
$nsim at 4.5 "$cbr stop"
$nsim at 5.0 "finish"

# Executa a simulação
$nsim run