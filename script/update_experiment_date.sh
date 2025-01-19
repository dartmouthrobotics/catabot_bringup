#!/bin/bash

function update_index() {
    filename="/home/catabot-5/index.txt"
    counter=$(cat $filename)
    ((counter++))
    echo "$counter" > $filename
}

# first
function update_experiment_date() {
    filename="/home/catabot-5/index.txt"
    
    # Generate a timestamp
    CURRENT_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

    echo "$CURRENT_TIME" > $filename
}

#update_experiment_date
update_index
