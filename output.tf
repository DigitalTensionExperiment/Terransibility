output "instance" {
  value = "${aws_instance.EC2_test.public_ip}"
}

output "rds" {
  value = "${aws_db_instance.db.endpoint}"
}