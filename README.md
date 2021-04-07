# Cockroach DB terraform config

### Tasks

- [x] Create a VPC
- [x] Create an EC2 instance
- [x] Create security group to allow personal IP and vpc CIDR
- [x] Create security group to allow access to db port from the security group instances
- [x] Attach security group to the instance
- [x] add user data to install cockroach db on the instance
- [x] Root Cert key setup
- [x] locally generate node crt and key
- [x] copy the generated files to the node
- [x] start the cockroachdb instance and join the cluster
- [] Create load balancer and attach the instances
- [] create a script to remove the node from the cluster on deletion

### Generating CA cert key pair

```
mkdir certs safe-dir
openssl genrsa -out safe-dir/ca.key 2048
chmod 400 safe-dir/ca.key
openssl req \
-new \
-x509 \
-config conf/ca.conf \
-key safe-dir/ca.key \
-out certs/ca.crt \
-days 365 \
-batch
touch index.txt
echo '01' > serial.txt
```

# Instructions

Check the `terraform.tfvars` and modify it as required

Details on keys in the file

```
ami_id        Base AMI for instances
personal_cidr CIDR block of your IP, used for SSH and dashboard access whitelist
db_port       Database port that the instance is listening on
ssh_key_name  SSH key used for authetication after the setup
cluster_size  Number of nodes
```

You need to generate the CA key and cert using the instruction given above.

Once done `terraform apply` will create the cluster.

Follow the steps for creating a client cert and using it to initialize the cluster:
https://www.cockroachlabs.com/docs/stable/deploy-cockroachdb-on-aws.html

# Improvements

- Add load balancer for cluster
- add steps to scale down the cluster(you can only scale up without errors right now)
- use bastion host for accessing the cluster.

