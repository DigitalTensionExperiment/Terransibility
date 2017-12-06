resource "aws_instance" "EC2_test" {
  ami = "${lookup(var.AMIS, var.aws_region)}"
  instance_type = "t2.micro"

  # we want this instance to launch in a certain subnet
  ## a subnet which belongs to only one VPC
  subnet_id = "${aws_subnet.public.id}"

  # One or more security groups can be added to this instance
  vpc_security_group_ids = ["${aws_security_group.public.id}"]

  key_name = "${aws_key_pair.auth.key_name}"

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
    delete_on_termination = true
  }

}

# The root volume of 8GB still exists
# We're just adding an extra 20 Gigs

# To add extra space to the root volume itself
# use root_block_device in the aws_instance resource;

resource "aws_ebs_volume" "ebs-volume1" {
  availability_zone = "${var.aws_region}"
  size = 20
  type = "gp2" # general purpose
  tags {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume1-attachment" {
  device_name = "/dev/xvdh"
  instance_id = "${aws_instance.EC2_test.id}"
  volume_id = "${aws_ebs_volume.ebs-volume1.id}"
}



# Install and OpenVPN server at boot time
resource "aws_instance" "vpn_server" {

  ami = "${lookup(var.AMIS, var.aws_region)}"
  instance_type = "t2.micro"

  subnet_id = "${aws_subnet.public.id}"

  vpc_security_group_ids = ["${aws_security_group.public.id}"]

  key_name = "${aws_key_pair.auth.key_name}"

  # userdata
  # #!/bin/bash indicates a script
  # the \n means new line
  # user_data = "#!/bin/bash\nwget http://swupdate.openvpn.org/as/openvpn-as-2.1.2-Ubuntu14.amd_64.deb\ndpkg -i openvpn-as-2.1.2-Ubuntu14.amd_64.deb"

  # better than a direct script string, use the template system:
  # here, user_data uses a cloudinit config that's rendered
  user_data = "${data.template_cloudinit_config.cloudinit-example.rendered}"

}



# Specifying a private IP for an EC2 instance
resource "aws_instance" "privateIP_specified" {
  ami = "${lookup(var.AMIS, var.aws_region)}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  private_ip = ""
}

# Specifying a public IP: EIP (Elastic IP addresses)
resource "aws_eip" "EIP_example" {
  instance = "${aws_instance.privateIP_specified.id}"
  vpc = true
}



# Adding a zone
resource "aws_route53_zone" "domain-com" {
  name = "domain.com"
}

resource "aws_route53_record" "server1-record" {
  name = "server1.domain.com"
  type = "A"
  ttl = "300"
  zone_id = "${aws_route53_zone.domain-com.id}"
  records = ["${aws_eip.EIP_example.public_ip}"]
}






























