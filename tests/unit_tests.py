import pytest
from app import app


def test_homepage(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b'Welcome to the Car App' in response.data

def test_add_car(client):
    response = client.post('/car', data={"model": "Tesla", "license": "123-ABC", "owner": "Elon"})
    assert response.status_code == 302

def test_get_all_cars(client):
    response = client.get('/cars')
    assert response.status_code == 200
    assert b'Tesla' in response.data

def test_get_specific_car(client):
    response = client.get('/cars/<car_id>')
    assert response.status_code == 200
    assert b'Elon' in response.data

def test_update_car(client):
    response = client.post('/car/<car_id>', data={"model": "Updated Tesla", "license": "456-DEF", "owner": "Updated Elon"})
    assert response.status_code == 302

def test_delete_car(client):
    response = client.post('/car/delete/<car_id>')
    assert response.status_code == 302
