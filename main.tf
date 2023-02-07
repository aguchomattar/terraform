// Define el provider de AWS
provider "aws" {
  region = local.region
}

locals {
  region = "eu-east-1"
  ami = var.ubuntu_ami [local.region]
}

//Data source para las AZ
data "aws_subnet" "public_subnet" {
  for_each = var.servidores
  availability_zone = "${local.region}${each.value.az}"
}

// Define una instancia EC2 con ami Ubuntu
resource "aws_instance" "servidor" {
  for_each = var.servidores
  ami                    = local.ami
  instance_type          = var.tipo_instancia
  subnet_id              = data.aws_subnet.public_subnet[each.key].id
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]

  // Definimos un "here data" que es usado durante el cloud init
  user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install -y busybox-static
                echo "Hola terraformers! soy ${each.value.nombre}" > index.html
                nohup busybox httpd -f -p ${var.puerto_servidor} &
                EOF

  tags = {
    Name = each.value.nombre
  }
}



// Definimos un security group para la instancia
resource "aws_security_group" "mi_grupo_de_seguridad" {
  name = "primer-servidor-sg"

  ingress {
    security_groups = [aws_security_group.alb.id]
    description     = "acceso al puerto 8080 desde el exterior"
    from_port       = var.puerto_servidor
    to_port         = var.puerto_servidor
    protocol        = "TCP"
  }

}

//Definimos el load balancer
resource "aws_lb" "alb" {
  name               = "terraform-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [for subnet in data.aws_subnet.public_subnet : subnet.id]
}

//Definimos grupo de seguridad para el ALB
resource "aws_security_group" "alb" {
  name = "alb-sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "acceso al puerto 80 desde el exterior"
    from_port   = var.puerto_lb
    to_port     = var.puerto_lb
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "acceso al puerto 8080 desde nuestro servidor"
    from_port   = var.puerto_servidor
    to_port     = var.puerto_servidor
    protocol    = "TCP"
  }
}

data "aws_vpc" "deffault" {
  default = true
}

resource "aws_lb_target_group" "this" {
  name     = "terraform-alb-target-group"
  port     = var.puerto_lb
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = var.puerto_servidor
    protocol = "HTTP"
  }
}

//Attachment para el servidor 1
resource "aws_lb_target_group_attachment" "servidor" {
  for_each = var.servidores
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.servidor[each.key].id
  port             = var.puerto_servidor
}



//Listenner para el LB
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.puerto_lb
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}