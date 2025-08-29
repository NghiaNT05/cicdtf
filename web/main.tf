#ec2
data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}


resource "aws_key_pair" "name" {
  key_name   = "my-key01"
  public_key = file("~/.ssh/id_ed25519.pub")  # lưu ý là file public key
}


resource "aws_instance" "bastion_host" {
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id = var.pubsub[0] # optional
  vpc_security_group_ids = [var.sg_bastion]
  key_name = aws_key_pair.name.key_name
  tags = {
    Name = "bastion host"
  }
}
resource "aws_instance" "frontend" {
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id = var.pubsub[0]
  vpc_security_group_ids = [var.sg_web]
  key_name = aws_key_pair.name.key_name
  tags = {
    Name = "frontend"
  }
}
resource "aws_instance" "backend" {
  ami = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id = var.prisub[0]
  vpc_security_group_ids = [var.sg_application]
  key_name = aws_key_pair.name.key_name
  tags ={
    Name = "backend"
  }
}
resource "aws_db_instance" "main" {
  identifier = "mydb-instance"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  username = var.db_username
  password = var.db_password
  db_name = "mydatabase"
  vpc_security_group_ids = [var.sg_dp]
  db_subnet_group_name = var.db_subnet_group_name
  multi_az = false
  skip_final_snapshot = true
  publicly_accessible = false
  tags = {
    Name = "my_rds_databse"
  }
}