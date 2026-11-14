import 'package:rental_car/domain/models/car.dart';

abstract class CarRepository {
  List<Car> getAllCars();

  void updateCar(Car car);
}