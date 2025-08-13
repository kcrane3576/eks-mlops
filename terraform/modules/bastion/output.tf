output "instance_id" {
  sensitive = true
  value     = aws_instance.bastion
}

output "security_group_id" {
  value = aws_security_group.bastion.id
}