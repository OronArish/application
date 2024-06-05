#!/bin/bash

set -e

# Base URL for the application
BASE_URL="http://nginx-container:80"

# Define car details
model="Tesla"
license="123-ABC"
owner="Elon"

# Add new car
add_response=$(curl -s -X POST -d "model=$model&license=$license&owner=$owner" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded")
echo "Add response: $add_response"

# Assuming the add response includes the ID of the car
# Extracting car ID using a placeholder method - adjust based on your actual response format
car_id=$(echo $add_response | grep -o '"id":"\([^"]*\)' | cut -d':' -f2 | tr -d '"')

# Get all cars
all_cars=$(curl -s -X GET "$BASE_URL/cars")
echo "All cars: $all_cars"

# Update car - replace '66601c6bbf9be378332f8db5' with $car_id which is dynamically extracted
update_response=$(curl -s -X POST -d "model=$model&license=$license&owner=New Owner" "$BASE_URL/car/$car_id" -H "Content-Type: application/x-www-form-urlencoded")
echo "Update response: $update_response"

# Delete car
delete_response=$(curl -s -X POST "$BASE_URL/car/delete/$car_id")
echo "Delete response: $delete_response"
