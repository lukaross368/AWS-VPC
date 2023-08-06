#!/bin/bash

key_pair_path=$1
local_dir_path=$2
target_server=$3
jump_server=$4

# Copy files to jump server
scp -i ${key_pair_path} -r ${local_dir_path} ec2-user@${jump_server}:/home/ec2-user

# Copy files from jump server to backend app server
ssh -i ${key_pair_path} ec2-user@${jump_server} "scp -i ${key_pair_path} -r ${local_dir_path} ec2-user@${target_server}:/home/ec2-user"

# Execute docker-compose on backend app server
ssh -i ${key_pair_path} ec2-user@${target_server} "cd VPC_WEBAPP && docker-compose up -d"
