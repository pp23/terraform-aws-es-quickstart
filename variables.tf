variable "profile" {
  description = "AWS profile to use"
  default     = "playground"
}

variable "region" {
  description = "AWS region to use"
}

variable "domain_name" {
  description = "Name of the AWS ES cluster"
  default     = "demo-es-vpc-tf"
}

variable "vpc_id" {
  description = "VPC"
}

# NOTE: This variable has to be configured.
#       The default parameter is only used to tell terraform which type to expect.
# FIXME: Currently this does not work for more than one subnet.
#       module.es.module.es.aws_elasticsearch_domain.es_vpc: 1 error(s) occurred:
#       aws_elasticsearch_domain.es_vpc: ValidationException: You must specify exactly one subnet.
#       status code: 400, request id: aea153c2-8fde-11e8-8486-17623168248f
variable "vpc_subnet_ids" {
  description = "Subnets the ES cluster should be created in."
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type to use for ES nodes and master"
  default     = "t2.small.elasticsearch"
}

variable "jump_ami" {
  description = "AMI to use for the jump station. If the parameter is not set, no jum-instance will be created"
  default     = "" // ami-afd15ed0 ... eu-central-1 Amazon Linux 2 LTS ( amzn2-ami-hvm-2017.12.0.20180509-x86_64-gp2 )
}

variable "instance_key" {
  description = "Name of the ssh key to access the jump instance."
  default     = ""
}

variable "ebs_volume_size" {
  description = "Size of the volume for the cluster instances in GB."
  default     = "10"
}

variable "instance_count" {
  description = "Number of instances in the cluster."
  default     = 1
}

variable "es_version" {
  description = "The elastic search version to be used."
  default     = 6.3
}

variable "create_iam_service_linked_role" {
  description = "Whether to create IAM service linked role for AWS ElasticSearch service. Can be only one per AWS account."
  type        = bool
  # Creation of an already existent role is not possible and IAM roles are region independent.
  # So we need only one role for the whole account to avoid errors if we deploy more than one region.
  default     = false
}

variable "advanced_options" {
  description = "Map of key-value string pairs to specify advanced configuration options. Note that the values for these configuration options must be strings (wrapped in quotes) or they may be wrong and cause a perpetual diff, causing Terraform to want to recreate your Elasticsearch domain on every apply."
  type        = map(string)
  default     = {"rest.action.multi.allow_explicit_index" = "true"}
}
