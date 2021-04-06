module "vpc" {
  source = "./vpc"
}

resource "aws_security_group" "default" {
  name        = "cockroachdb"
  description = "Allow dashboard and db port access"
  vpc_id      = module.vpc.id

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
  ami                          = var.ami_id
  associate_public_ip_address  = true
  instance_type                = "t2.micro"
  key_name                     = var.ssh_key_name
  subnet_id                    = module.vpc.subnet_id
  security_groups              = [aws_security_group.default.id]

  volume_tags = { Name = "test" }

  tags = {
    Name = "testInstance"
  }
}

