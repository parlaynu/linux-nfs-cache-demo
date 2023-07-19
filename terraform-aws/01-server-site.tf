## common variables

locals {
  server_site_name = "${var.project}.${var.server_site.name}"
}

## create the VPC

resource "aws_vpc" "server_site" {
  cidr_block           = var.server_site.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = local.server_site_name
  }
}


## tag default VPC resources

resource "aws_default_route_table" "server_site" {
  default_route_table_id = aws_vpc.server_site.default_route_table_id
  tags = {
    Name = local.server_site_name
  }
}

resource "aws_default_security_group" "server_site" {
  vpc_id = aws_vpc.server_site.id
  tags = {
    Name = "${local.server_site_name}.internal"
  }

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "server_site_external" {
  name        = "external"
  description = "Allow external inbound traffic"
  vpc_id = aws_vpc.server_site.id
  tags = {
    Name = "${local.server_site_name}.external"
  }
}

resource "aws_security_group_rule" "server_site_egress" {
  security_group_id = aws_security_group.server_site_external.id
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "server_site_ssh" {
  security_group_id = aws_security_group.server_site_external.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${data.external.my_public_ip.result["my_public_ip"]}/32"]
}

resource "aws_security_group_rule" "server_site_wireguard" {
  security_group_id = aws_security_group.server_site_external.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = var.vpn_port
  to_port           = var.vpn_port
  cidr_blocks       = ["${data.aws_instance.vpn_client.public_ip}/32"]
}

## create the internet gateway

resource "aws_internet_gateway" "server_site" {
  vpc_id = aws_vpc.server_site.id
  tags = {
    Name = "${local.server_site_name}"
  }
}

## create the public subnets and routes

resource "aws_subnet" "server_site_public" {
  vpc_id = aws_vpc.server_site.id
  cidr_block = cidrsubnet(var.server_site.cidr_block, 2, 0)
  availability_zone = var.server_site.zone

  tags = {
    Name = "${local.server_site_name}.pub"
  }
}

resource "aws_route_table_association" "server_site_public" {
  route_table_id = aws_vpc.server_site.main_route_table_id
  subnet_id      = aws_subnet.server_site_public.id
}

resource "aws_route" "server_site_public_default" {
  route_table_id = aws_vpc.server_site.main_route_table_id
  gateway_id     = aws_internet_gateway.server_site.id
  destination_cidr_block = "0.0.0.0/0"
}


## create the private subnets and routes

resource "aws_subnet" "server_site_private" {
  vpc_id = aws_vpc.server_site.id
  cidr_block = cidrsubnet(var.server_site.cidr_block, 2, 1)
  availability_zone = var.server_site.zone

  tags = {
    Name = "${local.server_site_name}.prv"
  }
}

resource "aws_route_table" "server_site_private" {
  vpc_id = aws_vpc.server_site.id
  tags = {
    Name = "${local.server_site_name}.prv"
  }
}

resource "aws_route_table_association" "server_site_private" {
  route_table_id = aws_route_table.server_site_private.id
  subnet_id      = aws_subnet.server_site_private.id
}

resource "aws_route" "server_site_private_default" {
  route_table_id = aws_route_table.server_site_private.id
  network_interface_id   = data.aws_instance.vpn_server.network_interface_id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [
    null_resource.vpn_server_ready
  ]
}


## the vpn server

resource "aws_spot_instance_request" "vpn_server" {
  ami           = var.ami_for_region[var.server_site.region]
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key_server.key_name
  vpc_security_group_ids      = [aws_default_security_group.server_site.id, aws_security_group.server_site_external.id]
  subnet_id                   = aws_subnet.server_site_public.id
  private_ip                  = cidrhost(aws_subnet.server_site_public.cidr_block, 6)
  associate_public_ip_address = true
  source_dest_check           = false
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-instance.sh.tpl", {
      server_name = "vpn-server"
    })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.server_site_name}.vpn"
  }
}

data "aws_instance" "vpn_server" {
  instance_id = aws_spot_instance_request.vpn_server.spot_instance_id
}

# an artificial dependency on the instances to wait for them to be
# in the running state. required by some resources such as routes
# with the instance_id as the target.
resource "null_resource" "vpn_server_ready" {
  
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = data.aws_instance.vpn_server.public_ip
      user = "ubuntu"
      private_key = file(local.ssh_private_key_file)
    }

    inline = [
      "ping -c 2 localhost"
    ]
  }
  
  depends_on = [
    local_file.ssh_private_key
  ]
}

resource "null_resource" "vpn_server" {

  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.server_site.region
      TAG_RESOURCE_ID = data.aws_instance.vpn_server.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${local.server_site_name}.vpn"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.vpn_server.spot_instance_id
  }
}

resource "null_resource" "vpn_server_src_dst_check" {
  provisioner "local-exec" {
    command = "scripts/ec2-disable-src-dst-check.sh"
    
    environment = {
      AWS_PROFILE = var.aws_profile
      AWS_REGION  = var.server_site.region
      INSTANCE_ID = data.aws_instance.vpn_server.id
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.vpn_server.spot_instance_id
  }
}

## the nfs server

locals {
  nfs_server_disk = "/dev/xvdd"
}

resource "aws_spot_instance_request" "nfs_server" {
  ami           = var.ami_for_region[var.server_site.region]
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key_server.key_name
  vpc_security_group_ids      = [aws_default_security_group.server_site.id]
  subnet_id                   = aws_subnet.server_site_private.id
  private_ip                  = cidrhost(aws_subnet.server_site_private.cidr_block, 6)
  associate_public_ip_address = false
  source_dest_check           = true
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-instance.sh.tpl", {
      server_name = "nfs-server"
  })
  
  ebs_block_device {
    device_name = local.nfs_server_disk
    volume_size = 20
    encrypted = true
  }
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.server_site_name}.nfs"
  }
}

data "aws_instance" "nfs_server" {
  instance_id = aws_spot_instance_request.nfs_server.spot_instance_id
}

resource "null_resource" "nfs_server" {
  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.server_site.region
      TAG_RESOURCE_ID = data.aws_instance.nfs_server.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${local.server_site_name}.nfs"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.nfs_server.spot_instance_id
  }
}





