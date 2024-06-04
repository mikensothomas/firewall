#!/bin/bash

# Configurações de rede
ip addr add 192.0.3.2/24 dev eth1
ip link set eth1 up
ip addr add 192.0.2.3/24 dev eth0
ip link set eth0 up

# Habilitar encaminhamento de pacotes
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpar regras existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

iptables -A INPUT -i lo -j ACCEPT

# Bloquear qualquer acesso direto da Internet para a estação de trabalho
iptables -A FORWARD -i eth0 -o eth1 -m state --state NEW -j DROP

# Permitir conexões de saída da estação de trabalho para a Internet para HTTP, HTTPS (portas 80 e 443)
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 443 -j ACCEPT

# Permitir tráfego de saída para serviços de e-mail (SMTP, IMAP, POP nas portas 465, 587, 995, 143, 993)
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 465 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 587 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 995 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 143 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 993 -j ACCEPT

# Restringir o acesso ao banco de dados. Somente o servidor de Aplicações pode acessar o banco de dados postgresql (porta 5432)
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 5432 -s 192.0.2.8 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 5432 -j DROP

# Restringir o acesso às portas 80 e 443 da SubredeLocal
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 443 -j ACCEPT

# Restringir o acesso ao Servidor de Aplicações à SubredeLocal
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -d 192.0.3.2 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 443 -d 192.0.3.2 -j ACCEPT

# Redirecionamento e Encaminhamento
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Logging: Registrar tentativas de conexões bloqueadas
iptables -A FORWARD -j LOG --log-prefix "FORWARD DROPPED: " --log-level 4

# Executar o contêiner em loop
tail -f /dev/null
