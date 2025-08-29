#app
variable "prisub" {
    type = list(string)
}
variable "sg_application" {
    type = string
    description = "Security Group ID for application tier"

}
#web
variable "pubsub" {
     type = list(string)

}
variable "sg_web" {
    type = string

}
variable "sg_dp" {
    type = string

}
variable "sg_bastion" {
    type = string

}
variable "db_username" {
  type = string
  sensitive = true
}
variable "db_password" {
  type = string
  sensitive = true
}
variable "db_subnet_group_name" {
  type        = string
  description = "rds_subnet group"
}

