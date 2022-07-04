## common variables

locals {
  client_site_name = "${var.project}.${var.client_site.name}"
}

## create the VPC

resource "aws_vpc" "client_site" {
  provider = aws.client
  
  cidr_block           = var.client_site.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = local.client_site_name
  }
}


## tag default VPC resources

resource "aws_default_route_table" "client_site" {
  provider = aws.client
  
  default_route_table_id = aws_vpc.client_site.default_route_table_id
  tags = {
    Name = local.client_site_name
  }
}

resource "aws_default_security_group" "client_site" {
  provider = aws.client
  
  vpc_id = aws_vpc.client_site.id
  tags = {
    Name = "${local.client_site_name}.internal"
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

resource "aws_security_group" "client_site_external" {
  provider = aws.client
  
  name        = "external"
  description = "Allow external inbound traffic"
  vpc_id = aws_vpc.client_site.id
  tags = {
    Name = "${local.client_site_name}.external"
  }
}

resource "aws_security_group_rule" "client_site_egress" {
  provider = aws.client
  
  security_group_id = aws_security_group.client_site_external.id
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "client_site_ssh" {
  provider = aws.client
  
  security_group_id = aws_security_group.client_site_external.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${data.external.my_public_ip.result["my_public_ip"]}/32"]
}

## create the internet gateway

resource "aws_internet_gateway" "client_site" {
  provider = aws.client
  
  vpc_id = aws_vpc.client_site.id
  tags = {
    Name = "${local.client_site_name}"
  }
}

## create the public subnets and routes

resource "aws_subnet" "client_site_public" {
  provider = aws.client
  
  vpc_id = aws_vpc.client_site.id
  cidr_block = cidrsubnet(var.client_site.cidr_block, 2, 0)
  availability_zone = var.client_site.zone

  tags = {
    Name = "${local.client_site_name}.pub"
  }
}

resource "aws_route_table_association" "client_site_public" {
  provider = aws.client
  
  route_table_id = aws_vpc.client_site.main_route_table_id
  subnet_id      = aws_subnet.client_site_public.id
}

resource "aws_route" "client_site_public_default" {
  provider = aws.client
  
  route_table_id = aws_vpc.client_site.main_route_table_id
  gateway_id     = aws_internet_gateway.client_site.id
  destination_cidr_block = "0.0.0.0/0"
}


## create the private subnets and routes

resource "aws_subnet" "client_site_private" {
  provider = aws.client
  
  vpc_id = aws_vpc.client_site.id
  cidr_block = cidrsubnet(var.client_site.cidr_block, 2, 1)
  availability_zone = var.client_site.zone

  tags = {
    Name = "${local.client_site_name}.prv"
  }
}

resource "aws_route_table" "client_site_private" {
  provider = aws.client
  
  vpc_id = aws_vpc.client_site.id
  tags = {
    Name = "${local.client_site_name}.prv"
  }
}

resource "aws_route_table_association" "client_site_private" {
  provider = aws.client
  
  route_table_id = aws_route_table.client_site_private.id
  subnet_id      = aws_subnet.client_site_private.id
}

resource "aws_route" "client_site_private_default" {
  provider = aws.client
  
  route_table_id = aws_route_table.client_site_private.id
  network_interface_id   = data.aws_instance.vpn_client.network_interface_id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [
    null_resource.vpn_client_ready
  ]
}


## the vpn client

resource "aws_spot_instance_request" "vpn_client" {
  provider = aws.client
  
  ami           = var.ami_for_region[var.client_site.region]
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key_client.key_name
  vpc_security_group_ids      = [aws_default_security_group.client_site.id, aws_security_group.client_site_external.id]
  subnet_id                   = aws_subnet.client_site_public.id
  private_ip                  = cidrhost(aws_subnet.client_site_public.cidr_block, 6)
  associate_public_ip_address = true
  source_dest_check           = false
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-instance.sh.tpl", {
      server_name = "vpn-client"
    })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.client_site_name}.vpn"
  }
}

data "aws_instance" "vpn_client" {
  provider = aws.client
  
  instance_id = aws_spot_instance_request.vpn_client.spot_instance_id
}

# an artificial dependency on the instances to wait for them to be
# in the running state. required by some resources such as routes
# with the instance_id as the target.
resource "null_resource" "vpn_client_ready" {
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = data.aws_instance.vpn_client.public_ip
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

resource "null_resource" "vpn_client" {
  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.client_site.region
      TAG_RESOURCE_ID = data.aws_instance.vpn_client.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${local.client_site_name}.vpn"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.vpn_client.spot_instance_id
  }
}

resource "null_resource" "vpn_client_src_dst_check" {
  provisioner "local-exec" {
    command = "scripts/ec2-disable-src-dst-check.sh"
    
    environment = {
      AWS_PROFILE = var.aws_profile
      AWS_REGION  = var.client_site.region
      INSTANCE_ID = data.aws_instance.vpn_client.id
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.vpn_client.spot_instance_id
  }
}

## the nfs cache

locals {
  nfs_cache_disk = "/dev/xvdd"
}

resource "aws_spot_instance_request" "nfs_cache" {
  provider = aws.client
  
  ami           = var.ami_for_region[var.client_site.region]
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key_client.key_name
  vpc_security_group_ids      = [aws_default_security_group.client_site.id]
  subnet_id                   = aws_subnet.client_site_private.id
  private_ip                  = cidrhost(aws_subnet.client_site_private.cidr_block, 6)
  associate_public_ip_address = false
  source_dest_check           = true
  disable_api_termination     = false

  ebs_block_device {
    device_name = local.nfs_cache_disk
    volume_size = 20
    encrypted = true
  }
  
  user_data = templatefile("templates/ec2-setup-instance.sh.tpl", {
      server_name = "nfs-cache"
  })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.client_site_name}.nfs-cache"
  }
}

data "aws_instance" "nfs_cache" {
  provider = aws.client
  
  instance_id = aws_spot_instance_request.nfs_cache.spot_instance_id
}

resource "null_resource" "nfs_cache" {
  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.client_site.region
      TAG_RESOURCE_ID = data.aws_instance.nfs_cache.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${local.client_site_name}.nfs-cache"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.nfs_cache.spot_instance_id
  }
}


## the nfs client

resource "aws_spot_instance_request" "nfs_client" {
  provider = aws.client
  
  ami           = var.ami_for_region[var.client_site.region]
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key_client.key_name
  vpc_security_group_ids      = [aws_default_security_group.client_site.id]
  subnet_id                   = aws_subnet.client_site_private.id
  private_ip                  = cidrhost(aws_subnet.client_site_private.cidr_block, 7)
  associate_public_ip_address = false
  source_dest_check           = true
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-instance.sh.tpl", {
      server_name = "nfs-client"
    })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.client_site_name}.nfs-client"
  }
}

data "aws_instance" "nfs_client" {
  provider = aws.client
  
  instance_id = aws_spot_instance_request.nfs_client.spot_instance_id
}

resource "null_resource" "nfs_client" {
  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.client_site.region
      TAG_RESOURCE_ID = data.aws_instance.nfs_client.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${local.client_site_name}.nfs-client"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.nfs_client.spot_instance_id
  }
}








