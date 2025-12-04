# 🚀 Deploy BlindX na AWS com Terraform

Este diretório contém a infraestrutura como código (IaC) para deploy do BlindX na AWS.

## 📋 Pré-requisitos

1. **Terraform** instalado ([Download](https://www.terraform.io/downloads))
2. **AWS CLI** configurado com suas credenciais
3. Conta AWS com permissões para criar EC2, Security Groups, etc.

## ⚙️ Configurar AWS CLI

```bash
aws configure
# AWS Access Key ID: <sua-access-key>
# AWS Secret Access Key: <sua-secret-key>
# Default region: us-east-1
# Default output format: json
```

## 🚀 Deploy

```bash
# 1. Entrar na pasta terraform
cd terraform

# 2. Inicializar Terraform
terraform init

# 3. Ver o plano de execução
terraform plan

# 4. Aplicar (criar infraestrutura)
terraform apply
# Digite "yes" para confirmar
```

## 📤 Outputs

Após o deploy, você verá:

```
app_url     = "http://X.X.X.X"
ssh_command = "ssh -i blindx-key.pem ec2-user@X.X.X.X"
```

## 🔗 Acessar a Aplicação

Aguarde ~3-5 minutos após o deploy para o build finalizar, depois acesse:

```
http://<IP-PUBLICO>
```

## 🔐 Conectar via SSH

```bash
ssh -i blindx-key.pem ec2-user@<IP-PUBLICO>
```

## 📊 Verificar Status do App

```bash
# Na EC2:
sudo systemctl status blindx
sudo journalctl -u blindx -f
```

## 🗑️ Destruir Infraestrutura

```bash
terraform destroy
# Digite "yes" para confirmar
```

## 💰 Custos Estimados

| Recurso    | Tipo     | Custo (us-east-1)        |
| ---------- | -------- | ------------------------ |
| EC2        | t2.micro | **Gratuito** (Free Tier) |
| Elastic IP | Em uso   | **Gratuito**             |
| EBS        | 20GB gp3 | ~$1.60/mês               |

> ⚠️ Elastic IP **cobra** se não estiver associado a uma instância em execução!

## 🔧 Personalização

Edite as variáveis no `main.tf`:

```hcl
variable "aws_region" {
  default = "us-east-1"  # Altere a região
}

variable "instance_type" {
  default = "t2.micro"   # Altere o tamanho
}
```
