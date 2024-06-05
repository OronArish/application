#!/bin/bash

# Base URL for the application
BASE_URL="http://nginx-container:80"  

CAR_ID="665ebab33d5624a22a0f647e"

# Test adding a car
model="Tesla"
license="123-ABC"
owner="Elon"

# Functions should be declared before use
function add_car() {
    echo "Adding a new car..."
    response=$(curl -s -X POST -d "model=$1&license=$2&owner=$3" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded")
    echo ${response}
}

function get_all_cars() {
    echo "Fetching all cars..."
    response= $(curl -s -X GET "$BASE_URL/cars")
    echo ${response}
}

function update_car() {
    echo "Updating car with ID $1..."
    response=$(curl -s -X POST -d "model=$2&license=$3&owner=$4" "$BASE_URL/car/$1" -H "Content-Type: application/x-www-form-urlencoded")
    echo ${response}
}

function delete_car() {
    echo "Deleting car with ID $1..."
    response=$(curl -s -X POST "$BASE_URL/car/delete/$1")
}

