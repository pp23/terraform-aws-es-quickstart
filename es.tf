// Create Security Group to handle access to AWS ES
resource "aws_security_group" "es_allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // HTTPS access has to be configured explicitly
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Configuration for JumpStation to access ES and Kibana
resource "aws_instance" "es_jump" {
  count                       = length(var.jump_ami) > 0 ? 1 : 0
  ami                         = var.jump_ami
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.es_allow_all.id]
  subnet_id                   = var.vpc_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = var.instance_key

  tags = {
    Name = "ES Jump Station"
  }
}

// Configure terraform community module for AWS ES
module "es" {
  source      = "github.com/terraform-community-modules/tf_aws_elasticsearch?ref=v1.3.0"
  domain_name = var.domain_name

  // Create ES inside a VPC
  vpc_options = {
    security_group_ids = [aws_security_group.es_allow_all.id]
    subnet_ids         = var.vpc_subnet_ids
  }

  es_version            = var.es_version
  instance_count        = var.instance_count
  instance_type         = var.instance_type
  dedicated_master_type = var.instance_type
  advanced_options      = var.advanced_options
  es_zone_awareness     = false
  ebs_volume_size       = var.ebs_volume_size
  create_iam_service_linked_role  = var.create_iam_service_linked_role
}

