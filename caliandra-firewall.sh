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

# Permitir tráfego de entrada relacionado e estabelecido
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir HTTP e HTTPS de entrada
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Permitir DNS
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# Permitir tráfego SMTP e IMAP
iptables -A INPUT -p tcp --dport 465 -j ACCEPT
iptables -A INPUT -p tcp --dport 587 -j ACCEPT
iptables -A INPUT -p tcp --dport 995 -j ACCEPT
iptables -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -j ACCEPT

# Regras específicas para acesso ao banco de dados
iptables -A INPUT -p tcp --dport 5432 -s 192.0.3.0/24 -j ACCEPT

# Registrar tentativas de conexões bloqueadas
iptables -A INPUT -j LOG --log-prefix "FW-Blocked: "

# Mantém o contêiner rodando
tail -f /dev/null
