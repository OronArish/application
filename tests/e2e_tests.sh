#!/bin/bash

set -e

# Base URL for the application
BASE_URL="http://nginx-container:80"  

CAR_ID="665ebab33d5624a22a0f647e"

# Test adding a car
model="Tesla"
license="123-ABC"
owner="Elon"

# add new car
curl -s -X POST -d "model=$1&license=$2&owner=$3" "$BASE_URL/car" -H "Content-Type: application/x-www-form-urlencoded"

# get all cars
curl -s -X GET "$BASE_URL/cars"

# update car
curl -s -X POST -d "model=$2&license=$3&owner=$4" "$BASE_URL/car/66601c6bbf9be378332f8db5" -H "Content-Type: application/x-www-form-urlencoded")
   
# delete
curl -s -X POST "$BASE_URL/car/delete/$1"


