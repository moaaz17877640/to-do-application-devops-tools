resource "aws_vpc" "to-vpc" {
  cidr_block                     = "10.0.0.0/16"
  ipv6_cidr_block                = "::/56"
  ipv6_ipam_pool_id              = "ipam-pool-id" 
  enable_dns_support             = true

  tags = {
    Name = "to-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.to-vpc.id
  availability_zone = "eu-north-1a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet_1"
  }
}
resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.to-vpc.id
  availability_zone = "eu-north-1b"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet_2"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.to-vpc.id

  tags = {
    Name = "firxt_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.to-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.to-vpc.ipv6_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.to-vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6_http2" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.to-vpc.ipv6_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
############################################################################################
resource "aws_security_group" "allow_tls2" {
  name        = "allow_tls2"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.to-vpc.id

  tags = {
    Name = "second_security_group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv42" {
  security_group_id = aws_security_group.allow_tls2.id
  cidr_ipv4         = aws_vpc.to-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv62" {
  security_group_id = aws_security_group.allow_tls2.id
  cidr_ipv6         = aws_vpc.to-vpc.ipv6_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv42_http" {
  security_group_id = aws_security_group.allow_tls2.id
  cidr_ipv4         = aws_vpc.to-vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv62_http" {
  security_group_id = aws_security_group.allow_tls2.id
  cidr_ipv6         = aws_vpc.to-vpc.ipv6_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv42" {
  security_group_id = aws_security_group.allow_tls2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv62" {
  security_group_id = aws_security_group.allow_tls2.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.to-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_egress_only_internet_gateway" "example" {
  vpc_id = aws_vpc.to-vpc.id

  tags = {
    Name = "to-do-egress-only-igw"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.to-vpc.id

  tags = {
    Name = "to-do-igw"
  }
}
resource "aws_network_acl" "to_acl1" {
  vpc_id = aws_vpc.to-vpc.id


  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "to_acl"
  }
}

resource "aws_network_acl" "to_acl2" {
  vpc_id = aws_vpc.to-vpc.id


  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "to_acl"
  }
}


resource "aws_network_acl_association" "acl1_ass1" {
  network_acl_id = aws_network_acl.to_acl1.id
  subnet_id      = aws_subnet.subnet_1.id
}

resource "aws_network_acl_association" "acl1_ass2" {
  network_acl_id = aws_network_acl.to_acl1.id
  subnet_id      = aws_subnet.subnet_2.id
}


resource "aws_internet_gateway_attachment" "attach_igw" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.to-vpc.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.route_table.id
}
