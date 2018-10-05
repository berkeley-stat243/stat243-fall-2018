#!/bin/bash

# instructions for obtaining Wikipedia traffic data from AWS
# Chris Paciorek, October 2017

# start ec2 instance in us-east-1 (ssh key ec2-east.pem) with volume snap-753dfc1c as 2nd ebs volume on /dev/sdf (not /dev/sdb) with at least 320GB

# mount the data on /tmp/data
mkdir /tmp/data
sudo mount /dev/xvdf /tmp/data
cd /tmp/data/wikistats/pagecounts

# install Globus personal
wget https://s3.amazonaws.com/connect.globusonline.org/linux/stable/globusconnectpersonal-latest.tgz
tar xzf globusconnectpersonal-latest.tgz
cd globusconnectpersonal-2.3.3/

apt-get update
apt-get install python
sudo apt-get install python-pip
pip install globus-cli

# login and set up Globus endpoint
globus login

globus endpoint create --personal aws-wiki
./globusconnectpersonal -start -restrict-paths r/tmp/data

# via globus browser access, transfer to Savio scratch:
# /global/scratch/paciorek/wikistats/raw
# 115 GB in 0:22 (22 minutes), 88 MB/s
