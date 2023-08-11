#!/bin/bash

key_pair_path=$1
local_dir_path=$2
target_server=$3
jump_server=$4

# Copy key_pair_to_jump_server
scp -i ${key_pair_path} -r ${key_pair_path} ec2-user@${jump_server}:/home/ec2-user

# Copy files to jump server
scp -i ${key_pair_path} -r ${local_dir_path} ec2-user@${jump_server}:/home/ec2-user

# Copy files from jump server to web_server
ssh -i ${key_pair_path} ec2-user@${jump_server} "scp -i ${key_pair_path} -r ${local_dir_path} ec2-user@${target_server}:/home/ec2-user"

# Execute docker-compose web-server to start up html app
ssh -i ${key_pair_path} ec2-user@${target_server} "cd vpc_webapp && docker-compose up -d"

