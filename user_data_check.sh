#!/bin/bash

timeout=${timeout}

end=$((SECONDS + timeout))

while [ $SECONDS -lt $end ]; do
  if [ -f /var/log/user_data.finish ]; then
    echo "User data completed successfully"
    exit 0
  elif [ -f /var/log/user_data.fail ]; then
    echo "User data has finished with errors"
    tail -n 15 /var/log/user-data.log
    exit 1
  else
    echo "Waiting for user data script to be completed"
  fi
  sleep 5
done

echo "User data did not complete within timeout"
tail -n 15 /var/log/user-data.log
exit 1