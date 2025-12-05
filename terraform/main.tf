# ============================================
# BlindX - Infraestrutura AWS com Terraform
# ============================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider AWS - Altere a região se necessário
provider "aws" {
  region = var.aws_region
}

# ============================================
# VARIÁVEIS
# ============================================

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro" # Free Tier eligible
}

variable "key_name" {
  description = "Nome da key pair para SSH"
  type        = string
  default     = "blindx-key"
}

# ============================================
# DATA SOURCES
# ============================================

# Busca a AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================
# SECURITY GROUP
# ============================================

resource "aws_security_group" "blindx_sg" {
  name        = "blindx-security-group"
  description = "Security group para BlindX"

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (porta 80)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App Spring Boot (porta 8080)
  ingress {
    description = "Spring Boot"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (opcional)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída - permitir tudo
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "blindx-sg"
    Project = "BlindX"
  }
}

# ============================================
# KEY PAIR (gera automaticamente)
# ============================================

resource "tls_private_key" "blindx_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "blindx_key" {
  key_name   = var.key_name
  public_key = tls_private_key.blindx_key.public_key_openssh
}

# Salva a chave privada localmente
resource "local_file" "private_key" {
  content         = tls_private_key.blindx_key.private_key_pem
  filename        = "${path.module}/blindx-key.pem"
  file_permission = "0400"
}

# ============================================
# EC2 INSTANCE
# ============================================

resource "aws_instance" "blindx_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.blindx_key.key_name
  vpc_security_group_ids = [aws_security_group.blindx_sg.id]

  # Script de inicialização (User Data)
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Atualizar sistema
              yum update -y
              
              # Instalar Java 17
              yum install -y java-17-amazon-corretto git
              
              # Clonar repositório
              cd /home/ec2-user
              git clone https://github.com/Ohlipeh/BlindX.git
              cd BlindX
              
              # Dar permissão ao Maven Wrapper
              chmod +x mvnw
              
              # Build do projeto
              ./mvnw clean package -DskipTests
              
              # Criar serviço systemd
              cat > /etc/systemd/system/blindx.service <<EOL
              [Unit]
              Description=BlindX Spring Boot Application
              After=network.target
              
              [Service]
              Type=simple
              User=ec2-user
              WorkingDirectory=/home/ec2-user/BlindX
              ExecStart=/usr/bin/java -jar /home/ec2-user/BlindX/target/blindx-0.0.1-SNAPSHOT.jar
              Restart=always
              RestartSec=10
              
              [Install]
              WantedBy=multi-user.target
              EOL
              
              # Ajustar permissões
              chown -R ec2-user:ec2-user /home/ec2-user/BlindX
              
              # Habilitar e iniciar serviço
              systemctl daemon-reload
              systemctl enable blindx
              systemctl start blindx
              
              # Redirecionar porta 80 para 8080
              iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
              
              EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name    = "blindx-server"
    Project = "BlindX"
  }
}

# ============================================
# ELASTIC IP (IP fixo)
# ============================================

resource "aws_eip" "blindx_eip" {
  instance = aws_instance.blindx_server.id
  domain   = "vpc"

  tags = {
    Name    = "blindx-eip"
    Project = "BlindX"
  }
}

# ============================================
# OUTPUTS
# ============================================

output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.blindx_server.id
}

output "public_ip" {
  description = "IP público (Elastic IP)"
  value       = aws_eip.blindx_eip.public_ip
}

output "app_url" {
  description = "URL da aplicação"
  value       = "http://${aws_eip.blindx_eip.public_ip}"
}

output "ssh_command" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i blindx-key.pem ec2-user@${aws_eip.blindx_eip.public_ip}"
}
