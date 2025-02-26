provider "aws" {
    region = "ap-south-1"
}

module "ec2-instance" {
    source = "./modules/test"
    instance_type = "t2.micro"
    ami_id = "ami-0d682f26195e9ec0f"
    volume_size = 15
}

output "public_ip" {
    value = module.ec2-instance.print_public_ip
}

output "pub_ip_pvt_machine" {
    value = module.ec2-instance.print_pvt_ip
}
