output "instance_id" {
  sensitive = true
  value     = aws_instance.bastion
}