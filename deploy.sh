#!/bin/bash

bank_0_host=$1
bank_1_host=$2

# copy web app files to first bank
scp -r "mykeypair.pem" -r vpc_webapp ec2-user@${bank_0_host}:/home/ec2-user

# copy web app files to second bank
scp -r "mykeypair.pem" -r vpc_webapp ec2-user@${bank_1_host}:/home/ec2-user

# run app in first bank 
ssh -i "mykeypair.pem" ec2-user@${bank_0_host} "cd vpc_webapp && docker-compose up"

# run app in second bank 
ssh -i "mykeypair.pem" ec2-user@${bank_1_host} "cd vpc_webapp && docker-compose up"