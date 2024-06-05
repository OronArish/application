#!/bin/bash

set -e
set -x  # Enable debugging

# Base URL for the application
BASE_URL="http://nginx-container:80"  

# Define car details
model="Tesla"
license="123-ABC"
owner="Elon"
car_id="66601c6bbf9be378332f8db5" 

function add_car() {
    echo "Adding new car..."
    local response=$(curl -s -X POST -d "model=$model&license=$license&owner=$owner" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded")
    echo "Add response: $response"
}

function get_all_cars() {
    echo "Retrieving all cars..."
    local response=$(curl -s -X GET "$BASE_URL/cars")
    echo "All cars: $response"
}

function update_car() {
    echo "Updating car..."
    local response=$(curl -s -X POST -d "model=$model&license=$license&owner=New Owner" "$BASE_URL/car/$car_id" -H "Content-Type: application/x-www-form-urlencoded")
    echo "Update response: $response"
}

function delete_car() {
    echo "Deleting car..."
    local response=$(curl -s -X POST "$BASE_URL/car/delete/$car_id")
    echo "Delete response: $response"
}

add_car
get_all_cars
update_car
delete_car
