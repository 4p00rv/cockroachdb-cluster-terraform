module "vpc" {
  source = "./vpc"
}

resource "aws_security_group" "default" {
  name        = "cockroachdb"
  description = "Allow dashboard and db port access"
  vpc_id      = module.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test"
  }
}

resource "aws_security_group_rule" "dashboard" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.cidr_block, var.personal_cidr]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.personal_cidr]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "db_port" {
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.default.id
  security_group_id = aws_security_group.default.id
}

resource "aws_instance" "cockroachdb" {
  ami = var.ami_id
  associate_public_ip_address  = true
  instance_type = "t2.micro"
  key_name = var.ssh_key_name
  subnet_id = module.vpc.subnet_id
  vpc_security_group_ids = [ aws_security_group.default.id ]
  user_data = templatefile("install.sh", {})

  volume_tags = { Name = "test" }

  tags = {
    Name = "testInstance"
  }
}

