provider "aws" {
  region = "us-east-2"

}

resource "aws_iam_role" "eks-kanban" {
  name = "eks-kanban"
  path = "/"

  assume_role_policy = <<EOF
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
EOF

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-kanban.id
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-kanban.id
}

resource "aws_eks_cluster" "eks-kanban-cluster" {
  name = "eks-kanban-cluster"
  role_arn = aws_iam_role.eks-kanban.arn

  vpc_config {
    subnet_ids         = [ aws_subnet.teamdr-public.id, aws_subnet.teamdr-public2.id ]
    security_group_ids = [ aws_security_group.teamdr-sg.id ]
  }

  depends_on = [
    aws_iam_role.eks-kanban,
  ]
}

resource "aws_iam_role" "eks1-kanban-role-workernodes" {
  name = "eks1-kanban-role-workernodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks1-kanban-role-workernodes.id
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks1-kanban-role-workernodes.id
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.eks1-kanban-role-workernodes.id
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks1-kanban-role-workernodes.id
}

resource "aws_eks_node_group" "eks-kanban-workernode-group" {
  cluster_name    = aws_eks_cluster.eks-kanban-cluster.id
  node_group_name = "eks-kanban-workernode-group"
  node_role_arn   = aws_iam_role.eks1-kanban-role-workernodes.arn
  subnet_ids      = [ aws_subnet.teamdr-public.id, aws_subnet.teamdr-public2.id ]
  instance_types = ["t2.micro"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  remote_access {
    ec2_ssh_key               = "teamdr"
    source_security_group_ids = [ aws_security_group.teamdr-sg.id ]
  }

  scaling_config {
    desired_size = 4
    max_size     = 4
    min_size     = 4
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}