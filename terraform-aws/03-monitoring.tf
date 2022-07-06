## the prometheus server

resource "aws_spot_instance_request" "prometheus" {
  provider = aws.client
  
  ami           = var.ami_for_region[var.client_site.region]
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key_client.key_name
  vpc_security_group_ids      = [aws_default_security_group.client_site.id]
  subnet_id                   = aws_subnet.client_site_private.id
  associate_public_ip_address = false
  source_dest_check           = true
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-instance.sh.tpl", {
      server_name = "prometheus"
    })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${local.client_site_name}.prometheus"
  }
}

data "aws_instance" "prometheus" {
  provider = aws.client
  
  instance_id = aws_spot_instance_request.prometheus.spot_instance_id
}

resource "null_resource" "prometheus" {
  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.client_site.region
      TAG_RESOURCE_ID = data.aws_instance.nfs_client.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${local.client_site_name}.prometheus"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.nfs_client.spot_instance_id
  }
}

