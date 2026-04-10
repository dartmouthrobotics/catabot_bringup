#!/bin/bash

TOPICS=(
    "/mavros/imu/data"
    "/miniAHRS/imu/data"
    "/ouster/points"
    "/blue/zed/right/color/raw/image/compressed"
    "/green/zed/right/color/raw/image/compressed"
    "/pink/zed/right/color/raw/image/compressed"
    "/red/zed/right/color/raw/image/compressed"
)

echo "-------------------------------------------------------------"
echo "📊 Persistent ROS 2 Performance Monitor"
echo "-------------------------------------------------------------"
printf "%-50s | %-12s\n" "TOPIC" "HZ / STATUS"
echo "-------------------------------------------------------------"

for TOPIC in "${TOPICS[@]}"
do
    # Step 1: Check if the graph even knows about this topic
    # If this fails, the node isn't running or is on a different Domain ID
    INFO=$(ros2 topic info "$TOPIC" 2>/dev/null)
    PUB_COUNT=$(echo "$INFO" | grep "Publisher count:" | awk '{print $3}')

    if [[ -z "$PUB_COUNT" || "$PUB_COUNT" -eq 0 ]]; then
        printf "%-50s | \e[31m%s\e[0m\n" "$TOPIC" "OFFLINE"
        continue
    fi

    # Step 2: Establish a connection. 
    # We use 'echo --count 1' with a long timeout to force discovery to finish.
    # This "wakes up" the connection for the HZ command.
    timeout 5s ros2 topic echo "$TOPIC" --count 1 > /dev/null 2>&1

    # Step 3: Now that the pipe is 'warm', measure frequency.
    # We use a 5s window and grep specifically for the decimal/number
    HZ_VAL=$(timeout 5s ros2 topic hz "$TOPIC" 2>/dev/null | grep "average rate:" | tail -n 1 | awk '{print $3}')
    
    if [ -n "$HZ_VAL" ]; then
        printf "%-50s | \e[32m%s Hz\e[0m\n" "$TOPIC" "$HZ_VAL"
    else
        # If Hz fails, we do one last check to see if we can see any raw data
        if timeout 2s ros2 topic echo "$TOPIC" --count 1 > /dev/null 2>&1; then
            printf "%-50s | \e[32m%s\e[0m\n" "$TOPIC" "STREAMING"
        else
            printf "%-50s | \e[33m%s\e[0m\n" "$TOPIC" "NO DATA"
        fi
    fi
done

echo "-------------------------------------------------------------"
