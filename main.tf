locals {
  user_data = [
    for item in range(1, var.instance_count + 1) : templatefile("${path.module}/user_data.sh", {
      hostname                    = var.instance_count > 1 && var.hostname != "" ? "${var.hostname}-${item}" : var.hostname
      user_data_script            = var.user_data
      check_internet_connectivity = var.check_internet_connectivity
    })
  ]
  user_data_check = templatefile("${path.module}/user_data_check.sh", {
    timeout = var.user_data_check_timeout
  })
}

resource "aws_instance" "ec2_instance" {
  count                       = var.create_ec2 ? var.instance_count : 0
  ami                         = var.ami
  instance_type               = var.type
  associate_public_ip_address = var.public_ip
  iam_instance_profile        = var.iam_role
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_groups
  subnet_id                   = var.subnets[count.index % length(var.subnets)]
  user_data_base64            = base64encode(local.user_data[count.index])
  user_data_replace_on_change = var.user_data_replace_on_change
  tags                        = merge({
    Name = var.instance_count > 1 && var.hostname != "" ? "${var.hostname}-${count.index + 1}" : var.hostname
  }, var.tags)
}

resource "null_resource" "check_user_data" {
  count      = var.create_ec2 && var.user_data_check ? var.instance_count : 0
  depends_on = [aws_instance.ec2_instance]
  triggers = {
    instance_id_list = join(",", aws_instance.ec2_instance[*].id)
  }
  connection {
    type        = var.user_data_check_connection_type
    host        = var.user_data_check_ip == "private" ? aws_instance.ec2_instance[count.index].private_ip : aws_instance.ec2_instance[count.index].public_ip
    user        = var.user_data_check_username
    password    = var.user_data_check_password
    private_key = var.user_data_check_private_key
  }
  provisioner "remote-exec" {
    inline = [local.user_data_check]
  }
}