#!/bin/bash

key_pair_path=$1
local_dir_path=$2
deploy_script_path=$3
jump_server=$4
bank_0_host=$5
bank_1_host=$6

# Copy key_pair_to_jump_server
scp -i ${key_pair_path} -r ${key_pair_path} ec2-user@${jump_server}:/home/ec2-user

# Copy files to jump server
scp -i ${key_pair_path} -r ${local_dir_path} ec2-user@${jump_server}:/home/ec2-user

# Copy Deploy Script to jump server
scp -i ${key_pair_path} -r ${deploy_script_path} ec2-user@${jump_server}:/home/ec2-user

# SSH to jump server and execute deploy script 
ssh -i ${key_pair_path} ec2-user@${jump_server} "chmod u+x deploy.sh && sh deploy.sh ${bank_0_host} ${bank_1_host}"