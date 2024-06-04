#!/bin/bash

# Habilitar encaminhamento de pacotes
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpar regras existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# Regras de firewall

# Regras básicas
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir tráfego interno
iptables -A INPUT -s 192.0.3.0/24 -j ACCEPT

# Permitir tráfego de saída HTTP, HTTPS e e-mail
iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -p tcp --dport 465 -j ACCEPT
iptables -A FORWARD -p tcp --dport 587 -j ACCEPT
iptables -A FORWARD -p tcp --dport 995 -j ACCEPT
iptables -A FORWARD -p tcp --dport 143 -j ACCEPT
iptables -A FORWARD -p tcp --dport 993 -j ACCEPT

# Regras específicas para acesso ao banco de dados
iptables -A INPUT -p tcp --dport 5432 -s 192.0.3.0/24 -j ACCEPT

# Registrar tentativas de conexões bloqueadas
iptables -A INPUT -j LOG --log-prefix "FW-Blocked: "

# Mantém o contêiner rodando
tail -f /dev/null
