# Digital ocean configuration

This directory contains the terraform configuration for the Digital Ocean infrastructure.

Create a `terraform.tfvars` file with the following content:

```hcl
do_token = "YOUR DIGITAL OCEAN TOKEN"
project_name = "YOUR PROJECT NAME"
```

Then run the following commands:

```bash
terraform init
terraform apply
```

Hit `yes` when prompted.

**Do note that this only creates a k8s cluster. You need to configure networking on your own, since we can't factor in where you registered your domain and if you have an IPV4 reserved address or not.**