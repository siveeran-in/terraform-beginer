output "MyPublicIP" {
  value = aws_instance.web.public_ip
}

output "MyPublicDNS" {
  value = "http://${aws_instance.web.public_dns}"
}