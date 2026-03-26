provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────
# KEY PAIR
# ─────────────────────────────────────────
resource "aws_key_pair" "bms_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# ─────────────────────────────────────────
# VPC & NETWORKING
# ─────────────────────────────────────────
resource "aws_vpc" "bms_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "bms-vpc" }
}

resource "aws_internet_gateway" "bms_igw" {
  vpc_id = aws_vpc.bms_vpc.id
  tags   = { Name = "bms-igw" }
}

resource "aws_subnet" "bms_public_subnet" {
  vpc_id                  = aws_vpc.bms_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = { Name = "bms-public-subnet" }
}

resource "aws_route_table" "bms_rt" {
  vpc_id = aws_vpc.bms_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bms_igw.id
  }

  tags = { Name = "bms-route-table" }
}

resource "aws_route_table_association" "bms_rta" {
  subnet_id      = aws_subnet.bms_public_subnet.id
  route_table_id = aws_route_table.bms_rt.id
}

# ─────────────────────────────────────────
# SECURITY GROUP  (mirrors your console config)
# ─────────────────────────────────────────
resource "aws_security_group" "bms_sg" {
  name        = "bms-sg"
  description = "Security group for BMS project"
  vpc_id      = aws_vpc.bms_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node Exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes NodePort range
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SMTPS
  ingress {
    from_port   = 465
    to_port     = 465
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "bms-sg" }
}

# ─────────────────────────────────────────
# BMS SERVER  (Jenkins + SonarQube + Docker + K8s master)
# ─────────────────────────────────────────
resource "aws_instance" "bms_server" {
  ami                    = var.ubuntu_ami
  instance_type          = "t2.large"
  key_name               = aws_key_pair.bms_key.key_name
  subnet_id              = aws_subnet.bms_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bms_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = "bms-server" }
}

# ─────────────────────────────────────────
# KUBERNETES WORKER NODE 1
# ─────────────────────────────────────────
resource "aws_instance" "k8s_node1" {
  ami                    = var.ubuntu_ami
  instance_type          = "t2.large"
  key_name               = aws_key_pair.bms_key.key_name
  subnet_id              = aws_subnet.bms_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bms_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = "node1" }
}

# ─────────────────────────────────────────
# KUBERNETES WORKER NODE 2
# ─────────────────────────────────────────
resource "aws_instance" "k8s_node2" {
  ami                    = var.ubuntu_ami
  instance_type          = "t2.large"
  key_name               = aws_key_pair.bms_key.key_name
  subnet_id              = aws_subnet.bms_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bms_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = "node2" }
}

# ─────────────────────────────────────────
# MONITORING SERVER  (Prometheus + Grafana)
# ─────────────────────────────────────────
resource "aws_instance" "monitoring_server" {
  ami                    = var.ubuntu_ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bms_key.key_name
  subnet_id              = aws_subnet.bms_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bms_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = { Name = "monitoring-server" }
}
