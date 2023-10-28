#modules

module "mywebserver" {
  source = "./modules/webserver"
  ami = "ami-0a7cf821b91bcccbc"
  instance_type = "t2.micro"
}