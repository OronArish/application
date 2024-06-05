#!/bin/bash

set -e

BASE_URL="http://nginx-container:80"  

function check_website() {
    echo "Checking if the website is up..."
    if curl -s --head --request GET "$BASE_URL" | grep "200 OK" > /dev/null; then
        echo "The website is up and running."
    else
        echo "The website is not responding."
    fi
}

check_website()