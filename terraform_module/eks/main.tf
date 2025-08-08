provider "aws" {
    region = "us-east-2"
}
resource "aws_eks_cluster" "my_cluster" {
    name = "my-eks-cluster"
    role_arn = aws_iam_role.cluster_role.arn
    vpc_config {
      subnet_ids = ["subnet-084b469669dbc4ae9","subnet-09b5f106b09903aea","subnet-0e9b4ab2deecdb973"]

    }
    depends_on = [ aws_iam_role_policy_attachment.cluster_role_policy_attachment ]
}

resource "aws_iam_role" "cluster_role" {
    name = "eks-cluster-role-tf"
    assume_role_policy = jsonencode({
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
        
    })
  
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.cluster_role.name
  
}

resource "aws_eks_node_group" "eks_node_group" {
    cluster_name = aws_eks_cluster.my_cluster.name
    node_group_name = "my-node-group"
    node_role_arn = aws_iam_role.node_group_role.arn
    scaling_config {
      desired_size = 2
      min_size = 2
      max_size = 2
    }
    instance_types = ["t2.medium"]
    update_config {
      max_unavailable = 1
    }
    subnet_ids = ["subnet-084b469669dbc4ae9","subnet-09b5f106b09903aea","subnet-0e9b4ab2deecdb973"]

    depends_on = [ 
        aws_iam_role_policy_attachment.node_group_cluster_policy_attachment,
        aws_iam_role_policy_attachment.node_group_cni_policy_attachment,
        aws_iam_role_policy_attachment.node_group_container_registry_policy_attachment,
        aws_iam_role_policy_attachment.node_group_worker_node_policy_attachment
     ]
  
}

resource "aws_iam_role" "node_group_role" {
    name = "node-group-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "node_group_cni_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.node_group_role.name
  
}

resource "aws_iam_role_policy_attachment" "node_group_container_registry_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node_group_role.name
  
}

resource "aws_iam_role_policy_attachment" "node_group_cluster_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.node_group_role.name
  
}

resource "aws_iam_role_policy_attachment" "node_group_worker_node_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node_group_role.name
  
}


