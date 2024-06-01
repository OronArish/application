from flask import Flask, request, jsonify, render_template, redirect, url_for
from pymongo import MongoClient
from bson.objectid import ObjectId
import os
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

metrics = PrometheusMetrics(app)
# MongoDB connection
client = MongoClient(os.getenv('MONGODB_URI',"mongodb://mongo:27017/"))
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
    return redirect(url_for('home'))

@app.route('/car/<id>', methods=['POST'])
def update_car(id):
    car = {
        "model": request.form['model'],
        "license": request.form['license'],
        "owner": request.form['owner']
    }
    cars_collection.update_one({"_id": ObjectId(id)}, {"$set": car})
    return redirect(url_for('home'))

@app.route('/car/delete/<id>', methods=['POST'])
def delete_car(id):
    cars_collection.delete_one({"_id": ObjectId(id)})
    return redirect(url_for('home'))

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

# @app.route('/metrics', methods=['GET'])
# def get_metrics():
#     total_cars = cars_collection.count_documents({})
#     return jsonify({"total_cars": total_cars})

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
