output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks-kanban-cluster.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.eks-kanban-cluster.certificate_authority
}