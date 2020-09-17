#Protegendo um ambiente OCI com Firewall

Esses são os scripts que usei na minha apresentação para o GUOB onde falei um pouco de como montar uma arquitetura no OCI com foco em ter um Firewall como Gateway do ambiente.

Esse script cria os seguintes recursos:
Network:
- VCN
	-	 Subnet Privada
	-	Reserva de IP para a máquina de Firewall
	-	 Internet Gateway
	-	 Tabela de rota usando o Internet Gateway
	-	Security List que libera toda comunicação de internet para Firewall
- Subnet Pública
	-	 Tabela de Rotas apontando todos os pacotes para a interface  LAN do Firewall
	-	Security List liberando comunicação

- Compute
	-	 Uma VM com o Shape Intel 2.1 com uma placa de rede em cada subnet
	-	 Uma VM com o Shape AMD E2.1 com uma placa de rede na subnet privada


