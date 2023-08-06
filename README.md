
![vpc.drawio](vpc.drawio.png)
## Architecture Overview 

Custom VPC spanning 2 availability zones with a total of 2 public subnets and 2 private subnets.

Internet Gateway for routing traffic to the public facing application load balancer which then forwards traffic to EC2 Instances running in private subnets. 

Each EC2 is running docker and a single container. Container is running an Nginx web server hosting a static HTML file.

Single EC2 instance running in Public-2A to act as a jump server to allow for manual configuration of the EC2 application servers.

Also running a NAT gateway so EC2 instances in private subnets can send requests to the internet in order to pull docker binaries. 

Test html app by hitting the LB here: http://my-alb-766802215.eu-west-2.elb.amazonaws.com/

## VPC Information

In this section find the info regarding the VPC setup and its components. 
### CIDR Block

IPv4 CIDR Block: 10.0.0.0/16 (Subnet Mask:  255.255.0.0)
This gives a total of ~65,536 possible host IPs in our Network. 

### Subnets: 

Chosen to partition the network such that a subnet has a subnet mask of 255.255.255.0 and therefore ~ 250 Host IPs per subnet
Using this subnet mask on each subnet would allow up to 256 subnets (256 * 256 = 65,536)

- Name: Public-2A, Availability Zone: eu-west-2a, IPv4 CIDR Block: 10.0.1.0/24
- Name: Public-2B, Availability Zone: eu-west-2b, IPv4 CIDR Block: 10.0.2.0/24
- Name: Private-2A, Availability Zone: eu-west-2a, IPv4 CIDR Block: 10.0.3.0/24
- Name: Private-2B, Availability Zone: eu-west-2b, IPv4 CIDR Block: 10.0.4.0/24

### Public Route Table

Associations:
- (Implicit): Public-2A, Public-2B

Routes: 
- 10.0.0.0/16 -> local
- 0.0.0.0/0 -> MyIGW
### Private Route Table

Associations:
- (Explicit) : Private-2A, Private-2B

Routes:
-  10.0.0.0/16 -> local
- 0.0.0.0/0 -> MyNatGatewat-01

### Security Groups

- my-html-app-server-sg 
	- inbound rule: allow HTTP traffic on port 80, source: public-web (load balancer security group)
	- inbound rule: allow SSH traffic on port 22 , source: jump-server-sg
- public-web
	- inbound rule: open, outbound rule: open
- jump-server-sg
	- inbound rule: allow SSH traffic on port 22, source: 0.0.0.0/0

## Instances 

With all the information above we should have a running VPC and subnets with the correct security groups and routing configured. Now we can deploy the instances and load balancer we will need into our custom VPC.

#### Jump Server EC2 Instance

- Amazon Linux 
- Subnet: Public-2A
- Public IPv4 address
- security group: jump-server-sg

This instance is used as a connection proxy in order to configure private resources in the network 
#### EC2 HTML App Instances

- Amazon Linux 
- Subnets: Private-2A and Private-2B
- Private IPv4 addresses
- security group: my-html-app-server-sg

These instances are used to run an Nginx web server hosting a static html file. Using the jump server as a proxy, first I connected via SSH and downloaded docker binaries on each instance using the following commands.


```shell
sudo yum update -y 
sudo yum install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -l https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname%20-s)-$(uname%20-m)%20-o%20/usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```


Then I copied the necessary files to the respective EC2 instances to run the web app using the deploy.sh shell script found in this repo.

#### Application Load Balancer

Now we have our EC2 instances running our application we need a public facing load balancer to forward any traffic from outside our network to instances running in the private subnets.

First create a Target group that includes both HTML App instances (HTML App group)

- public facing
- Spanning both availability zones (Public-2A, Public-2B)
- Forward to target 'HTML App group' , HTTP traffic on port 80
- Security Group: public web