# Cockroach DB terraform config

### Tasks

- [x] Create a VPC
- [x] Create an EC2 instance
- [x] Create security group to allow personal IP and vpc CIDR
- [x] Create security group to allow access to db port from the security group instances
- [x] Attach security group to the instance
- [] Create load balancer and attach the instances
- [x] add user data to install cockroach db on the instance
- [x] Root Cert key setup
- [] add a step to add more nodes to the cluster.
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

