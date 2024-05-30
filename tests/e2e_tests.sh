#!/bin/bash

set -e

echo 'Running end-to-end tests...'

docker compose down
docker compose up -d

sleep 10

# Test adding a car
addCarResponse=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "model=Tesla&license=123-ABC&owner=Elon" http://localhost:80/car)
if [ "$addCarResponse" -ne 302 ]; then
  echo "Failed to add car"
  exit 1
fi

# Test fetching all cars
getCarsResponse=$(curl -s http://localhost:80/cars)
car_id=$(echo $getCarsResponse | jq -r '.[0]._id')
echo "Fetched Car ID: ${car_id}"

# Test fetching a specific car using the extracted ID
getCarResponse=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/cars/${car_id})
if [ "$getCarResponse" -ne 200 ]; then
  echo "Failed to fetch car with ID ${car_id}"
  exit 1
fi

# Test deleting a car using the extracted ID
deleteCarResponse=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:80/car/delete/${car_id})
if [ "$deleteCarResponse" -ne 302 ]; then
  echo "Failed to delete car with ID ${car_id}"
  exit 1
fi

docker compose down

echo "End-to-end tests passed."
