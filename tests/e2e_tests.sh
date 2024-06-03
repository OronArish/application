#!/bin/bash

# Base URL for the application
BASE_URL="http://localhost:5000"

# Function to perform a POST request to add a car and get back the ID
function add_car() {
    echo "Adding a new car..."
    response=$(curl -s -X POST -d "model=$1&license=$2&owner=$3" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded")
    echo $response | grep -o '"id": "[^"]*' | grep -o '[^"]*$' # Adjust based on your actual response format
}

# Function to get all cars
function get_all_cars() {
    echo "Fetching all cars..."
    curl -s -X GET "$BASE_URL/cars"
}

# Function to update a car
function update_car() {
    echo "Updating car with ID $1..."
    curl -s -o /dev/null -w "%{http_code}" -X POST -d "model=$2&license=$3&owner=$4" "$BASE_URL/car/$1" -H "Content-Type: application/x-www-form-urlencoded"
}

# Function to delete a car
function delete_car() {
    echo "Deleting car with ID $1..."
    curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/car/delete/$1"
}

# Test adding a car
model="Tesla"
license="123-ABC"
owner="Elon"
car_id=$(add_car "$model" "$license" "$owner")
echo "Added car ID: $car_id"

# Test updating a car
update_response=$(update_car "$car_id" "Updated Tesla" "456-DEF" "Updated Elon")
echo "Update car response status: $update_response"

# Test deleting a car
delete_response=$(delete_car "$car_id")
echo "Delete car response status: $delete_response"
