# This role has a trust relationship which allows
# to assume the role of ec2
resource "aws_iam_role" "ecs_agent_role" {
  name               = "${var.app_name}-ecs-agent"
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

  tags = merge({
    Name = "${var.app_name}-ecs-agent"
  }, var.tags)
}

# This is a policy attachment for the "ecs" role, it provides access
# to the the ECS service.
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

//# This is the role for the load balancer to have access to ECS.
//resource "aws_iam_role" "ecs_elb_role" {
//  name               = "${var.app_name}-ecs-elb-role"
//  assume_role_policy = <<EOF
//  {
//    "Version": "2012-10-17",
//    "Statement": [
//      {
//        "Sid": "",
//        "Effect": "Allow",
//        "Principal": {
//          "Service": "ecs.amazonaws.com"
//        },
//        "Action": "sts:AssumeRole"
//      }
//    ]
//  }
//  EOF
//
//  tags = merge({
//    Name = "${var.app_name}-ecs-elb-role"
//  }, var.tags)
//}
//
//# Attachment for the above IAM role.
//resource "aws_iam_policy_attachment" "ecs_elb" {
//  name       = "${var.app_name}_ecs_elb"
//  roles      = [aws_iam_role.ecs_agent_role.id]
//  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
//}
