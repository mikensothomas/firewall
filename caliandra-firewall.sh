# Habilitar encaminhamento de pacotes
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpar regras existentes
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

iptables -A INPUT -i lo -j ACCEPT

# Permitir todo o tráfego de saída
iptables -P OUTPUT ACCEPT

# Bloquear todo o tráfego de entrada por padrão
iptables -P INPUT DROP

# Permitir tráfego de entrada para pacotes relacionados e estabelecidos
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir conexões HTTP (porta 80) e HTTPS (porta 443) de entrada da RedePan para a Internet
iptables -A INPUT -p tcp --dport 80 -s 192.0.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -s 192.0.2.0/24 -j ACCEPT

# Permitir conexões DNS de entrada e saída (porta 53)
iptables -A INPUT -p udp --dport 53 -s 192.0.2.0/24 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -s 192.0.2.0/24 -j ACCEPT

# Permitir tráfego SMTP e IMAP de entrada para e-mail (portas 465, 587, 995, 143, 993)
iptables -A INPUT -p tcp --dport 465 -s 192.0.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 587 -s 192.0.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 995 -s 192.0.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 143 -s 192.0.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 993 -s 192.0.2.0/24 -j ACCEPT

# Restringir o acesso ao banco de dados. Somente o servidor de Aplicações pode acessar o banco de dados postgresql (porta 5432)
iptables -A INPUT -p tcp --dport 5432 -s 192.0.2.8 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -j DROP

# Logging: Registrar tentativas de conexões bloqueadas
iptables -A INPUT -j LOG --log-prefix "INPUT DROPPED: " --log-level 4

# Executar o contêiner em loop
tail -f /dev/null