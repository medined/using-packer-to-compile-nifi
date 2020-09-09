# Using Packer and Terraform To Create AMI With Apache NiFi Installed

GOAL: Create an AMI that compiles Apache NiFi and copied the result to S3.

After the `01-build-worker-image.sh` script is completed, you should have the `nifi-1.12.0-bin.tar.gz` file in your S3FS S3 bucket.

Technically, there is no reason to retain the AMI since the goal of this project is to create `nifi-1.12.0-bin.tar.gz` and put it in S3. You might find the technique of using `packer` to accomplish this goal to be somewhat round-a-bout. You would not be wrong, but this technique is easy to understand and definitely controls all variables.

## Technologies Used

* HashiCorp **Packer** (https://www.packer.io/) automates the creation of any type of machine image. It embraces modern configuration management by encouraging you to use automated scripts to install and configure the software within your Packer-made images. Packer brings machine images into the modern age, unlocking untapped potential and opening new opportunities.

* HashiCorp **Terraform** (https://www.terraform.io/) uses Infrastructure as Code to provision and manage any cloud, infrastructure, or service.

* **s3fs** (https://github.com/s3fs-fuse/s3fs-fuse) allows Linux and macOS to mount an S3 bucket via FUSE. s3fs preserves the native object format for files, allowing use of other tools like AWS CLI.

* **Apache NiFi** NiFi was built to automate the flow of data between systems. While the term 'dataflow' is used in a variety of contexts, we use it here to mean the automated and managed flow of information between systems.

## NOTE

Following this directions means that a new VPC will be created using the CIDR defined in `variables.tf`.

## Installation

```bash
wget https://releases.hashicorp.com/packer/1.6.2/packer_1.6.2_linux_amd64.zip
unzip packer_1.6.2_linux_amd64.zip
sudo mv packer /usr/local/bin

wget https://releases.hashicorp.com/terraform/0.13.2/terraform_0.13.2_linux_amd64.zip
unzip terraform_0.13.2_linux_amd64.zip
sudo mv terraform /usr/local/bin
```

## Setup

### Create IAM Role For Packer Builder

When creating your AMI, you might want access to S3 in order to get files. In order to do this work, the builder EC2 instance needs to have an IAM role associated with it. Create a role called `packer-builder` that has at least the `AmazonS3ReadOnlyAccess` policy.

* Create a file specifying the instance profile name.

```bash
cat <<EOF > source.me
export PACKER_BUILDER_INSTANCE_PROFILE="packer-builder"
EOF
```

### Create a PKI Key Pair

This is the key used to SSH into the EC2 instance. This technique is useful because it is independent of AWS. However, the AWS console will not show any key name for the EC2 instance. Basically, don't forget which key goes with which instance.

* Create a local SSH key. Don't use a passphrase. Use your own email, if desired. This command creates both `tf-packer.pem` and `tf-packer.pem.pub`.

```bash
EMAIL="john@example.com"
ssh-keygen -t rsa -C $EMAIL -f ./tf-packer.pem
```

### Configure Terraform Variables

Make suer to change the `aws_profile_name` and the `vpc_name`. Check that the `vpc_cidr` value is not already being used.

```bash
cat <<EOF > terraform.tfvars
aws_profile_name = "bluejay"
key_private_file = "./tf-packer.pem"
region = "us-east-1"
ssh_cdir_block = "0.0.0.0/0"
ssh_user = "centos"
target_environment = "dev"
vpc_cidr = "10.1.0.0/16"
vpc_name = "glox"
EOF
```

### Create S3 Bucket For S3FS

I like to use UUIDs in my bucket name to make them unique and opaque. The bucket name is stored in a file that is copied over to the AMI being created.

cat <<EOF > s3fs-bucket.txt
$(uuid)-s3fs
EOF

## Scripts

## Build the AMI.

```bash
./01-build-image.sh
```

## Provision the server.

```bash
./02-provision-server.sh
```

## SSH to server.

```bash
./03-ssh-to-server.sh
```

## Destroy the server.

```bash
./99-destroy-server.sh
```
