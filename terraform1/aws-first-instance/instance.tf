data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  # ami name=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*
  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  #root-device-type
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  #virtualization-type
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#EC2 instance resources

resource "aws_instance" "web" {

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tf-keypair.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  tags = {
    Name = "web"
  }

  user_data = file("${path.module}/shell.sh")

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "readme.md"
    destination = "/tmp/readme.md"
  }

  provisioner "local-exec" {
    working_dir= "/tmp" //created aws ec2 working dir 
    command = "echo ${self.public_ip} > ip_reader.txt"
  }

  //interpreter
  provisioner "local-exec" {
    interpreter = [ 
      "/usr/bin/python3", "-c"
     ]
    command = "print('HelloWorld')"
  }

  provisioner "local-exec" {
    command = "env > env.txt"
    environment = {
      envname = "envvalue"
    }
  }

  //take place when terraform start
  provisioner "local-exec" {
    on_failure = continue
    command = "echo 'at create'"
  }

  //take place when terraform delete
  provisioner "local-exec" {
    when = destroy
    command = "echo 'at delete'"
  }

  //remote-exec
  provisioner "remote-exec" {
    inline = [ 
      "ifconfig > /tmp/ipconfig.output",
      "echo 'hello this is been done with the help of remote-exec' > /tmp/echo.txt"
     ]
  }

  provisioner "remote-exec" {
    script = "./testscript.sh"
  }
}
