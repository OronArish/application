import time
import requests
import pytest

def test_add_car():
    response = requests.post(
        "http://localhost:80/car",
        data={"model": "Tesla", "license": "123-ABC", "owner": "Elon"},
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    assert response.status_code == 302, f"Failed to add car, got {response.status_code}"

def test_get_all_cars():
    response = requests.get("http://localhost:80/cars")
    assert response.status_code == 200, f"Failed to get cars, got {response.status_code}"
    car = response.json()[0]
    pytest.car_id = car["_id"]
    print(f"Fetched Car ID: {pytest.car_id}")

def test_get_specific_car():
    car_id = getattr(pytest, "car_id", None)
    assert car_id is not None, "No car ID fetched"
    response = requests.get(f"http://localhost:80/cars/{car_id}")
    assert response.status_code == 200, f"Failed to fetch car with ID {car_id}, got {response.status_code}"

def test_delete_car():
    car_id = getattr(pytest, "car_id", None)
    assert car_id is not None, "No car ID fetched"
    response = requests.post(f"http://localhost:80/car/delete/{car_id}")
    assert response.status_code == 302, f"Failed to delete car with ID {car_id}, got {response.status_code}"
