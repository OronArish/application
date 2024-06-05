#!/bin/bash

set -e
set -x  

BASE_URL="http://nginx-container:80"  

function check_website() {
    echo "Checking if the website is up..."
    response=$(curl --head --request GET "$BASE_URL")
    echo "Curl response: $response"
    if echo "$response" | grep "200 OK" > /dev/null; then
        echo "The website is up and running."
    else
        echo "The website is not responding."
    fi
}

check_website
