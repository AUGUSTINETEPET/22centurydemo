

resource "aws_vpc" "example" {
  cidr_block = "10.10.0.0/16"

  tags = {
    "Name" = "chatgpt-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.example.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
      "Name" = "chatgpt-pub-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.example.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "valuechatgpt-private-subnet"
  }
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = "${aws_vpc.example.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "chatgpt-SG"
  }

}

resource "aws_security_group" "app" {
  name        = "app"
  description = "Allow MySQL traffic"
  vpc_id      = "${aws_vpc.example.id}"

  ingress {
     from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "chatgpt-SG1"
  }
}

resource "aws_instance" "web" {
  count = 2
  ami           = "ami-06ba8f09b61b3421f"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  key_name = "dockerkeypair"

  tags = {
    "name" = "chatgpt-web-server"
  }
}
resource "aws_internet_gateway" "example" {
  vpc_id = "${aws_vpc.example.id}"

  tags = {
    "name" = "chatgpt-IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.example.id}"
   
}
}
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"

}