

variable "domain" {
    type = string
}

variable "instance_type" {
    type = string
    default = "t3.small.elasticsearch"
}

variable "elasticsearch_version" {
    type = string
    default = "7.10"
}

variable "tag_domain" {
    type = string
}

variable "volume_type" {
    type = string
    default = "gp2"
}

variable "ebs_volume_size" {
    type = number
    default = 10
}

variable "allowed_ip" {
    type = string
}