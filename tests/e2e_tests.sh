#!/bin/bash

# Base URL for the application
BASE_URL="http://localhost:80"

# Known car ID for testing (replace with a valid car ID from your API)
CAR_ID="665ebab33d5624a22a0f647e"

# Function to perform a POST request to add a car
function add_car() {
    echo "Adding a new car..."
    response=$(curl -s -X POST -d "model=$1&license=$2&owner=$3" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded")
}

# Function to get all cars
function get_all_cars() {
    echo "Fetching all cars..."
    curl -s -X GET "$BASE_URL/cars"
}

# Function to update a car
function update_car() {
    echo "Updating car with ID $1..."
    response=$(curl -s -X POST -d "model=$2&license=$3&owner=$4" "$BASE_URL/car/$1" -H "Content-Type: application/x-www-form-urlencoded")
}

# Function to delete a car
function delete_car() {
    echo "Deleting car with ID $1..."
    response=$(curl -s -X POST "$BASE_URL/car/delete/$1")
}

# Test adding a car
model="Tesla"
license="123-ABC"
owner="Elon"
add_car "$model" "$license" "$owner"

# Test updating a car using a known car ID
update_car "$CAR_ID" "Updated Tesla" "456-DEF" "Updated Elon"

# Test deleting a car using a known car ID
delete_car "$CAR_ID"
