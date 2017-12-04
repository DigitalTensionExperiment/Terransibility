resource "aws_instance" "EC2_test" {
  ami = "${lookup(var.AMIS, var.aws_region)}"
  instance_type = "t2.micro"

  # we want this instance to launch in a certain subnet
  ## a subnet which belongs to only one VPC
  subnet_id = "${aws_subnet.public.id}"

  # One or more security groups can be added to this instance
  vpc_security_group_ids = ["${aws_security_group.public.id}"]

  key_name = "${aws_key_pair.auth.key_name}"
}

resource "aws_ebs_volume" "" {
  availability_zone = "${var.aws_region}"
  size = 20
  type = "gp2" # general purpose
  tags {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume1-attachment" {
  device_name = "${}"
  instance_id = "${aws_instance.EC2_test.id}" 
  volume_id = "${}"
}