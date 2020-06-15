# Module to create AWS Elastic Container Service (ECS) cluster

terraform {
  required_version = ">= 0.12"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.vpc_name}-${var.name}-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_instance" {
  name = var.instance_log_group != "" ? var.instance_log_group : format("%s-instance", "${var.vpc_name}-${var.name}-ecs")
  tags        = var.tags
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "CloudwatchPutMetricData"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "InstanceLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      aws_cloudwatch_log_group.ecs_instance.arn
    ]
  }
}

resource "aws_iam_policy" "instance_policy" {
  name   = "${var.vpc_name}-${var.name}-ecs-instance-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.instance_policy.json
} 

resource "aws_iam_role" "ecs_instance" {
  name = "${var.name}-ecs-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "instance_policy" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}

resource "aws_security_group" "ecs_instance" {
  name        = "${var.vpc_name}-${var.name}-ecs-instance-sg"
  description = "Security Group managed by Terraform"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ecs_instance_egress_permit_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_instance.id
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    additional_user_data_script = var.additional_user_data_script
    ecs_cluster                 = aws_ecs_cluster.ecs_cluster.name
    log_group                   = aws_cloudwatch_log_group.ecs_instance.name
  }
}

data "aws_ami" "ecs_instance" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "user" {
  count      = var.instance_keypair != "" ? 0 : 1
  key_name   = var.name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_launch_configuration" "ecs_instance" {
  name_prefix          = "${var.vpc_name}-${var.name}-ecs-lc"
  image_id             = var.image_id != "" ? var.image_id : data.aws_ami.ecs_instance.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs_instance.name
  user_data            = data.template_file.user_data.rendered
  security_groups      = [aws_security_group.ecs_instance.id]
  key_name             = var.instance_keypair != "" ? var.instance_keypair : element(concat(aws_key_pair.user.*.key_name, list("")), 0)

  root_block_device {
    volume_size = var.instance_root_volume_size
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.vpc_name}-${var.name}-ecs-asg"

  launch_configuration = aws_launch_configuration.ecs_instance.name
  vpc_zone_identifier  = var.vpc_subnets
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_size

  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}
