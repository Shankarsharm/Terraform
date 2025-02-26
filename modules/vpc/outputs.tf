output "print_public_ip" {
    value = aws_instance.pub_instance.public_ip
}

output "print_pvt_ip" {
    value = aws_instance.pvt_instance.public_ip
}
