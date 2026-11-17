import 'dart:convert';

import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/domain/repositories/car_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarRepositoryImpl implements CarRepository {
  static const _storageKey = 'cars';

  static const _initialCars = [
    Car(id: 1,  name: 'Toyota Avanza',     dailyPrice: 545000,  lateFeePerHour: 50000),
    Car(id: 2,  name: 'Honda Brio',        dailyPrice: 495000,  lateFeePerHour: 40000),
    Car(id: 3,  name: 'Daihatsu Sigra',    dailyPrice: 495000,  lateFeePerHour: 40000),
    Car(id: 4,  name: 'Honda Mobilio',     dailyPrice: 545000,  lateFeePerHour: 50000),
    Car(id: 5,  name: 'Honda HR-V',        dailyPrice: 695000,  lateFeePerHour: 60000),
    Car(id: 6,  name: 'Honda Jazz',        dailyPrice: 645000,  lateFeePerHour: 60000),
    Car(id: 7,  name: 'Toyota New Avanza', dailyPrice: 695000,  lateFeePerHour: 60000),
    Car(id: 8,  name: 'Toyota New Innova', dailyPrice: 775000,  lateFeePerHour: 70000),
    Car(id: 9,  name: 'Pajero Sport',      dailyPrice: 1900000, lateFeePerHour: 190000),
    Car(id: 10, name: 'Fortuner',          dailyPrice: 1900000, lateFeePerHour: 190000),
  ];

  @override
  Future<List<Car>> getAllCars() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      await _saveAll(_initialCars.toList());
      return _initialCars.toList();
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((item) => _fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await _saveAll(_initialCars.toList());
      return _initialCars.toList();
    }
  }

  @override
  Future<void> updateCar(Car car) async {
    final cars = await getAllCars();
    final index = cars.indexWhere((c) => c.id == car.id);
    if (index == -1) return;

    cars[index] = car;
    await _saveAll(cars);
  }

  // Menulis seluruh listCar ke penyimpanan sebagai JSON.
  Future<void> _saveAll(List<Car> cars) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(cars.map(_toJson).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Map<String, dynamic> _toJson(Car car) => {
    'id': car.id,
    'name': car.name,
    'dailyPrice': car.dailyPrice,
    'lateFeePerHour': car.lateFeePerHour,
    'isAvailable': car.isAvailable,
  };

  Car _fromJson(Map<String, dynamic> json) => Car(
    id: json['id'] as int,
    name: json['name'] as String,
    dailyPrice: json['dailyPrice'] as int,
    lateFeePerHour: json['lateFeePerHour'] as int,
    isAvailable: json['isAvailable'] as bool,
  );
}