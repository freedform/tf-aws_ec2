#!/bin/bash

# Redirect all output to a log file
exec > /var/log/user-data.log 2>&1
set -x

start_time=$(date +%s)

echo "Set up hostname"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
hostnamectl set-hostname $INSTANCE_ID
echo $INSTANCE_ID > /etc/hostname
sed -i "s/127.0.0.1 .*/127.0.0.1 $INSTANCE_ID localhost/" /etc/hosts

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
  sleep 5
done

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