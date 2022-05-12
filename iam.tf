# ---
# EKS master
resource "aws_iam_role" "eks-master" {
    name = "eks-master-role"

    assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks-master.name
}

resource "aws_iam_role_policy_attachment" "eks-service" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role       = aws_iam_role.eks-master.name
}

#IAM Role for EKS pod execution
resource "aws_iam_role" "ekspodexecution" {
    name = "podexerole"
    assume_role_policy = data.aws_iam_policy_document.ekspodexecution_assume.json
}

data "aws_iam_policy_document" "ekspodexecution_assume" {
    statement {
      effect = "Allow"
      actions = [
          "sts:AssumeRole",
        ]
        principals {
          type = "Service"
          identifiers = [
              "eks-fargate-pods.amazonaws.com",
          ]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ekspodexecution1" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
    role = aws_iam_role.ekspodexecution.name
}

# ---
# EKS node
#resource "aws_iam_role" "eks-node" {
#    name = "eks-node-role"

#    assume_role_policy = <<POLICY
#    {
#        "Version": "2012-10-17",
#        "Statement": [
#            {
#                "Effect": "Allow",
#                "Principal": {
#                    "Service": "ec2.amazonaws.com"
#                },
#                "Action": "sts:AssumeRole"
#            }
#        ]
#    }
#    POLICY
#}

#resource "aws_iam_role_policy_attachment" "eks-worker-node" {
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#    role       = aws_iam_role.eks-node.name
#}

#resource "aws_iam_role_policy_attachment" "eks-cni" {
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#    role       = aws_iam_role.eks-node.name
#}

#resource "aws_iam_role_policy_attachment" "ecr-ro" {
#    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#    role       = aws_iam_role.eks-node.name
#}

#resource "aws_iam_instance_profile" "eks-node" {
#    name = "eks-node-profile"
#    role = aws_iam_role.eks-node.name
#}