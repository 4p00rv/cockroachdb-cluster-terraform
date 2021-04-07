variable "ami_id" {
  description = "Base ami to use for ami"
  type = string
}

variable "personal_cidr" {
  description = "personal ip to access the dashboard from"
  type = string
}

variable "db_port" {
  description = "Port on which database is listening"
  type = string
}

variable "ssh_key_name" {
  description = "SSH key to attach to the instance"
  type = string
}

variable "cluster_size" {
  description = "size of the cluster"
  type = number
}

variable "node_crt_pwd" {
  description = "Password for local key/crt generation"
  type = string
}

