variable "puerto_servidor" {
  description = "puerto para las instancias"
  type =  number
  default = 8080

  validation {
    condition = var.puerto_servidor > 0 && var.puerto_servidor <= 65536
    error_message = "El valor debe estar en 1 y 65535"
  }
}

variable "puerto_lb" {
  description = "puerto para el lb"
  type = number
  default = 80  
}

variable "tipo_instancia" {
  description = "tipo de instancias EC2"
  type = string
  default = "t2.micro"
}

variable "ubuntu_ami" {
  description = "AMI por region"
  type = map(string)

  default = {
    eu-east-1 = "ami-00874d747dde814fa" # Ubuntu en N. Virginia
    eu-east-2 = "ami-0ab0629dba5ae551d" # Ubuntu en Ohio
  }
}