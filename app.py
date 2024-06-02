from flask import Flask, request, jsonify, render_template, redirect, url_for
from pymongo import MongoClient
from bson.objectid import ObjectId
import os
import logging
from fluent import sender
from prometheus_flask_exporter import PrometheusMetrics
from logging.handlers import RotatingFileHandler

app = Flask(__name__)

metrics = PrometheusMetrics(app)

# Setup logging
file_handler = RotatingFileHandler('app.log', maxBytes=10240, backupCount=10)
file_handler.setLevel(logging.INFO)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
file_handler.setFormatter(formatter)

app.logger.addHandler(file_handler)
app.logger.setLevel(logging.INFO)

@app.before_request
def log_request_info():
    app.logger.info('Request: %s %s %s', request.method, request.path, request.get_data())

@app.after_request
def log_response_info(response):
    app.logger.info('Response: %s %s', response.status, response.get_data())
    return response

# MongoDB connection
client = MongoClient(os.getenv('MONGODB_URI', "mongodb://mongo:27017/"))
db = client.car_database
cars_collection = db.cars

@app.route('/')
def home():
    cars = list(cars_collection.find({}))
    for car in cars:
        car['_id'] = str(car['_id'])
    return render_template('index.html', cars=cars)

@app.route('/car', methods=['POST'])
def add_car():
    car = {
        "model": request.form['model'],
        "license": request.form['license'],
        "owner": request.form['owner']
    }
    cars_collection.insert_one(car)
    app.logger.info('Added car: %s', car)
    return jsonify({"message": "Car added successfully"}), 201

@app.route('/car/<id>', methods=['POST'])
def update_car(id):
    car = {
        "model": request.form['model'],
        "license": request.form['license'],
        "owner": request.form['owner']
    }
    result = cars_collection.update_one({"_id": ObjectId(id)}, {"$set": car})
    if result.matched_count:
        app.logger.info('Updated car: %s', car)
        return jsonify({"message": "Car updated successfully"}), 200
    else:
        return jsonify({"error": "Car not found"}), 404

@app.route('/car/delete/<id>', methods=['POST'])
def delete_car(id):
    result = cars_collection.delete_one({"_id": ObjectId(id)})
    if result.deleted_count:
        app.logger.info('Deleted car with id: %s', id)
        return jsonify({"message": "Car deleted successfully"}), 200
    else:
        return jsonify({"error": "Car not found"}), 404

@app.route('/cars', methods=['GET'])
def get_all_cars():
    cars = list(cars_collection.find({}))
    for car in cars:
        car['_id'] = str(car['_id'])
    return jsonify(cars)

@app.route('/cars/<id>', methods=['GET'])
def get_car(id):
    car = cars_collection.find_one({"_id": ObjectId(id)})
    if car is None:
        return jsonify({"error": "Car not found"}), 404
    car['_id'] = str(car['_id'])
    return jsonify(car)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False)
