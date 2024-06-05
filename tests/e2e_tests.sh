#!/bin/bash

set -e
set -x  # Print each command for debugging

BASE_URL="http://nginx-container:80"  

# Define car details
model="Tesla"
license="123-ABC"
owner="Elon"

function add_car() {
    echo "Testing Adding a New Car..."
    local add_response=$(curl -s -X POST -d "model=$model&license=$license&owner=$owner" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded")
    echo "Add response: $add_response"
    local car_id=$(echo "$add_response" | grep -o '"id":"[^"]*' | cut -d'"' -f4)  
    if [ -z "$car_id" ]; then
        echo "Failed to extract car ID from add response."
        return 1
    fi
    echo "Extracted Car ID: $car_id"
    echo $car_id  
}

function get_all_cars() {
    echo "Testing Retrieving All Cars..."
    local all_cars=$(curl -s -X GET "$BASE_URL/cars")
    echo "All cars: $all_cars"
}

function update_car() {
    local car_id=$1
    echo "Testing Updating Car..."
    local update_response=$(curl -s -X POST -d "model=$model&license=$license&owner=New Owner" "$BASE_URL/car/$car_id" -H "Content-Type: application/x-www-form-urlencoded")
    echo "Update response: $update_response"
}

function delete_car() {
    local car_id=$1
    echo "Testing Deleting Car..."
    local delete_response=$(curl -s -X POST "$BASE_URL/car/delete/$car_id")
    echo "Delete response: $delete_response"
}

# Main execution flow
car_id=$(add_car)
if [ "$car_id" ]; then
    get_all_cars
    update_car $car_id
    delete_car $car_id
else
    echo "Error adding car. Aborting tests."
    exit 1
fi
