provider "cloudinit" {}

data "template_file" "init-script" {
  template = "${file()}"
  vars {
    region = "${var.aws_region}"
  }
}

data "template_cloudinit_config" "cloudinit-example" {

  # Different file formats for cloudinit script
  gzip = false
  base64_encode = false
  # Cannot be passed as clear text

  "part" {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.init-script.rendered}"
  }
}






