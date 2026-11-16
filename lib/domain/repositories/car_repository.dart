import 'package:rental_car/domain/models/car.dart';

abstract class CarRepository {
  Future<List<Car>> getAllCars();

  Future<void> updateCar(Car car);
}