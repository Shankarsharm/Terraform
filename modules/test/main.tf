provider "aws" {
    region = "ap-south-1"
}

resource "aws_key_pair" "shankar" {
    key_name = "terraform_shankar"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pub_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "Public-subnet"
    }
}

resource "aws_subnet" "pvt_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"

    tags = {
        Name = "private-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "igw-my-vpc"
    }
}

resource "aws_route_table" "pub-rt-table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route_table_association" "pub-rt-associate" {
    subnet_id = aws_subnet.pub_subnet.id
    route_table_id = aws_route_table.pub-rt-table.id
}

resource "aws_eip" "my_eip" {
    vpc = true
}

resource "aws_nat_gateway" "pvt-ngw" {
    subnet_id = aws_subnet.pub_subnet.id
    allocation_id = aws_eip.my_eip.id

    tags = {
        Name = "pvt-ngw"
    }
}

resource "aws_route_table" "pvt-rt-table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.pvt-ngw.id
    }

    tags = {
        Name = "private-route-table"
    }   
}

resource "aws_route_table_association" "pvt-rt-associate" {
    subnet_id = aws_subnet.pvt_subnet.id
    route_table_id = aws_route_table.pvt-rt-table.id
}

resource "aws_security_group" "my_sg" {
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow-all-ssh-http"
    }
}

resource "aws_instance" "pub_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.pub_subnet.id
    vpc_security_group_ids = [aws_security_group.my_sg.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.shankar.key_name

    tags = {
        Name = "Public-access-machine"
    }

    root_block_device {
        volume_size = var.volume_size
        volume_type = "gp2"
    }
}

resource "aws_instance" "pvt_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.pvt_subnet.id
    vpc_security_group_ids = [aws_security_group.my_sg.id]
    key_name = aws_key_pair.shankar.key_name

    tags = {
        Name = "Private-machine"
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "10"
    }
}