# Public NACL Resources

locals {
  eks_public_nacl_rules = [
    { # Allow inbound HTTPS (443) from a specific public IP
      name        = "public_ingress_https"
      rule_number = 100
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = var.allowed_public_ingress_ip
      from_port   = 443
      to_port     = 443
    },
    { # Allow all inbound traffic from within the VPC
      name        = "public_ingress_from_vpc"
      rule_number = 101
      egress      = false
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr
      from_port   = null
      to_port     = null
    },
    { # Allow inbound ephemeral ports for return traffic from internet
      name        = "public_ingress_ephemeral"
      rule_number = 110
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
    { # Default deny all other inbound traffic
      name        = "public_ingress_deny_all"
      rule_number = 200
      egress      = false
      protocol    = "-1"
      rule_action = "deny"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    },
    { # Allow all outbound traffic to within the VPC
      name        = "public_egress_to_vpc"
      rule_number = 100
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr
      from_port   = null
      to_port     = null
    },
    { # Allow outbound HTTPS (443) to the internet
      name        = "public_egress_https"
      rule_number = 101
      egress      = true
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    { # Default deny all other outbound traffic
      name        = "public_egress_deny_all"
      rule_number = 200
      egress      = true
      protocol    = "-1"
      rule_action = "deny"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}

resource "aws_network_acl" "eks_public" {
  vpc_id     = aws_vpc.eks.id
  subnet_ids = aws_subnet.eks_public[*].id
  tags = {
    Name = "${var.environment}-eks-public-nacl"
  }
}

resource "aws_network_acl_rule" "eks_public" {
  for_each       = { for rule in local.eks_public_nacl_rules : rule.name => rule }
  network_acl_id = aws_network_acl.eks_public.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port == null ? null : each.value.from_port
  to_port        = each.value.to_port == null ? null : each.value.to_port
}

# Private NACL Resources

locals {
  eks_private_nacl_rules = [
    { # Allow all inbound traffic from within the VPC
      name        = "private_ingress_from_public"
      rule_number = 100
      egress      = false
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr
      from_port   = null
      to_port     = null
    },
    { # Allow inbound ephemeral ports for return traffic from NAT/internet
      name        = "private_ingress_ephemeral"
      rule_number = 110
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
    { # Default deny all other inbound traffic
      name        = "private_ingress_deny_all"
      rule_number = 200
      egress      = false
      protocol    = "-1"
      rule_action = "deny"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    },
    { # Allow outbound HTTPS (443) to the internet
      name        = "private_egress_https"
      rule_number = 99
      egress      = true
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    { # Allow all established outbound traffic (ephemeral ports)
      name        = "private_egress_ephemeral"
      rule_number = 100
      egress      = true
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
    { # Allow all outbound traffic to the VPC
      name        = "private_egress_to_vpc"
      rule_number = 101
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr
      from_port   = null
      to_port     = null
    },
    { # Default deny all other outbound traffic
      name        = "private_egress_deny_all"
      rule_number = 200
      egress      = true
      protocol    = "-1"
      rule_action = "deny"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}

resource "aws_network_acl" "eks_private" {
  vpc_id     = aws_vpc.eks.id
  subnet_ids = aws_subnet.eks_private[*].id

  tags = {
    Name = "${var.environment}-eks-private-nacl"
  }
}

resource "aws_network_acl_rule" "eks_private" {
  for_each       = { for rule in local.eks_private_nacl_rules : rule.name => rule }
  network_acl_id = aws_network_acl.eks_private.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port == null ? null : each.value.from_port
  to_port        = each.value.to_port == null ? null : each.value.to_port
}
