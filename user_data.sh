#!/bin/bash

# Redirect all output to a log file
exec > /var/log/user-data.log 2>&1
set -euxo pipefail
trap "touch /var/log/user_data.fail" EXIT

start_time=$(date +%s)

echo "Set up hostname"
instance_hostname=${hostname}
if [ -z "$instance_hostname" ]; then
  if [ "${imdsv2}" == "required"]; then
    IMDS_TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
    instance_hostname=$(curl -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
  else
    instance_hostname=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  fi
fi
hostnamectl set-hostname $instance_hostname
echo $instance_hostname > /etc/hostname
sed -i "s/127.0.0.1 .*/127.0.0.1 $instance_hostname localhost/" /etc/hosts

if [ "${check_internet_connectivity}" == "true" ]; then
echo "Checking internet connectivity..."
max_retries=10
retry_count=0
while ! ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; do
  echo "Internet is not reachable. Retrying in 5 seconds..."
  retry_count=$((retry_count + 1))
  if [ "$retry_count" -ge "$max_retries" ]; then
    echo "Maximum retries reached. Exiting."
    exit 1
  fi
  sleep 3
done
fi

# Start logging
echo "Starting user data script..."

${user_data_script}

# Record the end time
end_time=$(date +%s)

# Calculate the total execution time in seconds
execution_time=$((end_time - start_time))

# Convert execution time to a human-readable format (optional)
execution_minutes=$((execution_time / 60))
execution_seconds=$((execution_time % 60))

# Mark completion
echo "User data script completed successfully."
echo "Total execution time: $execution_minutes minutes and $execution_seconds seconds."
touch /var/log/user_data.finish
trap - EXIT