variable "instance_type" {
    description = "provide value that ec2 instance uses"
    type = string
}

variable "ami_id" {
    description = "provide ami machine image id"
    type = string
}

variable "volume_size" {
    description = "Ebs volume size"
    type = number
}
