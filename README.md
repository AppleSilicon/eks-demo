# Create VPC, EKS, S3, HTTP Server using Terraform

## Prerequisites
- AWS CLI
- kubectl
- Docker
- Python 3
- Terraform

## Step 1 - AWS CLI Login
1. Go to AWS Console, create a Access Key
1. open a Command Prompt / Terminal
```
aws configure

$ aws configure
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: ap-east-1
Default output format [None]: json
```

## Step 2 - Create the VPC, EKS, S3
```
cd vpc-eks-s3

terraform init
terraform plan
terraform apply
```

It will take ~10min to create about 60 resources on AWS. 
```
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Creating...
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Still creating... [10s elapsed]
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Still creating... [20s elapsed]
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Still creating... [30s elapsed]
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Still creating... [40s elapsed]
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Still creating... [50s elapsed]
module.eks.aws_eks_addon.this["aws-ebs-csi-driver"]: Creation complete after 54s [id=eks-demo:aws-ebs-csi-driver]
module.eks.time_sleep.this[0] (deposed object c9153ca5): Destroying... [id=2024-12-03T08:14:21Z]
module.eks.time_sleep.this[0]: Destruction complete after 0s

Apply complete! Resources: 60 added, 0 changed, 1 destroyed.

Outputs:

cluster_endpoint = "https://0E2327B7DAB12E56A33682AF9BFfgfgA9672.sk1.ap-east-1.eks.amazonaws.com"
cluster_name = "eks-demo"
cluster_security_group_id = "sg-05c1d45f4e358bcbd"
region = "ap-east-1"
```


Update the kubeconfig
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

## Step 3 - Create a ECR
Go to AWS Console, create a ECR with namespace/repo-name = demo/ecr


## Step 4 - Python HTTP Server

1. Build the Docker image of the http Server

```
cd ../http-server
docker buildx build --platform=linux/amd64 -t demo/ecr:latest .
```

2. tag and push the Docker image to a ECR

```        
docker tag demo/ecr:latest <userid>.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest
docker push <userid>.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest
```
## Step 5 - Use Terraform to deploy the HTTP Server to the EKS
1. Edit http-server.tf, give the correct URL of the Docker image you just pushed to ECR

```
image: <userid>.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest
```

2. Terraform apply
```
terraform init
terraform plan
terraform apply
```

## Step 6 - Verification of the deployed Python app being accessible through the service.

```
LOAD_BALANCER_HOSTNAME=$(kubectl get service http-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$LOAD_BALANCER_HOSTNAME
```

## Step 7 - Destroy the resources
```
cd ../vpc-eks-s3
terraform destroy
```

That's it. Thx!