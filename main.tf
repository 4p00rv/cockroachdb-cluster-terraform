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
  count = var.cluster_size

  ami = var.ami_id
  associate_public_ip_address  = true
  instance_type = "t2.micro"
  key_name = var.ssh_key_name
  subnet_id = module.vpc.subnet_id
  vpc_security_group_ids = [ aws_security_group.default.id ]
  user_data = file("${path.module}/install.sh")

  volume_tags = { Name = "test" }

  tags = {
    Name = "testInstance"
  }
}

resource "null_resource" "join-cluster" {
  count = var.cluster_size

  # Create cert and key for the node
  provisioner "local-exec" {
    # provision node cert key
    command = "${path.module}/generate_cert.sh"
    environment = {
      INTERNAL_IP = aws_instance.cockroachdb[count.index].private_ip
      EXTERNAL_IP = aws_instance.cockroachdb[count.index].public_ip
      DOMAIN = "test-${count.index}.local"
      INDEX = count.index
    }
  }

  provisioner "file" {
    source = "${path.module}/certs"
    destination = "~"

    # Use ssh agent to authenticate with remote
    # if this doesn't work make sure the key is added to your agent
    connection {
      user = "ec2-user"
      host = aws_instance.cockroachdb[count.index].public_ip
    }
  }

  # Remove local node.key file. we don't need it anymore.
  # It also prevents the failures for next resource creation.
  provisioner "local-exec" {
    command = "rm -f certs/node${count.index}.*"
  }



  provisioner "remote-exec" {
    inline = [ "sleep 10",
    "mv certs/node${count.index}.crt certs/node.crt.imp",
    "mv certs/node${count.index}.key certs/node.key.imp",
    "rm -f certs/node*.crt certs/node*.key certs/*.pem",
    "mv certs/node.key.imp certs/node.key",
    "mv certs/node.crt.imp certs/node.crt",
    "chmod -R 500 certs/",
    "/usr/local/bin/cockroach start --certs-dir=certs --advertise-addr=${aws_instance.cockroachdb[count.index].private_ip} --join=${join(",", aws_instance.cockroachdb.*.private_ip)} --cache=.25 --max-sql-memory=.25 --background --cert-principal-map=localhost:node" ]

    connection {
      user = "ec2-user"
      host = aws_instance.cockroachdb[count.index].public_ip
    }
  }
}
