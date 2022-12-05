data "aws_vpc" "bootcamp_vpc" {
  filter {
    name   = "tag:Name"
    values = ["bootcamp-vpc"]
  }
}

data "aws_subnet" "bootcamp_subnet" {
  filter {
    name   = "tag:Name"
    values = ["bootcamp-vpc"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "jenkins_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group para o servidor do Jenkins Server"
  vpc_id      = data.aws_vpc.bootcamp_vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "jenkins_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = "Jenkins-Server"
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = "terraform"
  monitoring             = true
  vpc_security_group_ids = [module.jenkins_sg.security_group_id]
  subnet_id              = data.aws_subnet.bootcamp_subnet.id
  user_data              = file("./jenkins.sh")

  tags = {
    Terraform = "true"
    Environment = "prod"
    Name = "Jenkins-Server"
    Alunos = "Fabiano e Diego"
  }
}


resource "aws_eip" "jenkins-ip" {
  instance = module.jenkins_ec2_instance.id
  vpc      = true
}

output "ip_acesso_jenkins" {
  value = "Acesse o Jenkins pela URL http://${aws_eip.jenkins-ip.public_ip}:80/"
}