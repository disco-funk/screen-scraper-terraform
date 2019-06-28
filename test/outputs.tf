# Instance tag
output "instance_tag" {
  description = "A list of the screen-scrape-ec2 instances"
  value       = aws_instance.direct-channel-mock.tags.Name
}

# Instance id
output "instance_id" {
  value = aws_instance.direct-channel-mock.id
}

# Outputs for terratest
output "region" {
  value = var.region
}

output "instance_public_ip" {
  value = aws_instance.direct-channel-mock.public_ip
}

//output "eip" {
//  value = aws_eip.direct-channel-eip.public_ip
//}
