provider "aws" {
  region  = "${var.region}"
  shared_credentials_files=["/home/luka/.aws/credentials","/home/luka/.aws/config"]
  profile = "default"
}