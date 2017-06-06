#!/bin/bash

export EC2_INSTANCE_ID=$(ec2metadata --instance-id)

mkdir -p efs_logs

./start_bayou.sh
