output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_id" {
  value = aws_vpc.myvpc.id
}

#outputs for server
output "prisub" {
  description = "List of private subnet IDs for App and DB Tier"
  value       = [for subnet in aws_subnet.private : subnet.id]
}
output "sg_application" {
  value = aws_security_group.app-tier-sg.id
}
#outputs for web
output "pubsub" { 
  description = "List of public subnet IDs for Web Tier"
  value       = [for subnet in aws_subnet.public : subnet.id]
}
output "sg_web" {
  value = aws_security_group.web_sg.id
}
##output for db
output "sg_dp" {
  value = aws_security_group.db_sg.id
}

#output for bastion
output "sg_bastion" {
  value = aws_security_group.bastion_sg.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}