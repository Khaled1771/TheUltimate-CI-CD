# Data sources
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-cluster-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security group for EKS nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Allow ALL traffic within the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all traffic between nodes"
  }
  
  # Allow ALL traffic from cluster security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "Allow all traffic from EKS control plane"
  }

  # Allow ALL outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.cluster_name}-node-sg"
    Environment = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Single security group rule for cluster communication
resource "aws_security_group_rule" "nodes_to_cluster_all_traffic" {
  description              = "Allow all traffic from the nodes to the cluster"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  type                     = "ingress"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  # Enable CloudWatch logs for troubleshooting
  enabled_cluster_log_types = ["api", "audit"]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.private_subnet_ids
  
  # Use the provided instance types
  instance_types = var.node_instance_types
  
  # Disk size
  disk_size = 20
  
  # Scaling configuration
  scaling_config {
    desired_size = var.node_desired_capacity
    max_size     = var.node_max_capacity
    min_size     = var.node_min_capacity
  }
  
  # Use configurable capacity type
  capacity_type = var.capacity_type
  
  update_config {
    max_unavailable = 1
  }

  # Labels
  labels = {
    "role" = "node"
    "environment" = var.environment
  }

  # SSH access
  remote_access {
    ec2_ssh_key = var.key_name
  }

  tags = {
    Name        = "${var.cluster_name}-node-group"
    Environment = var.environment
  }

  depends_on = [
    aws_eks_cluster.main
  ]
}