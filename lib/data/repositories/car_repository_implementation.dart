import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/domain/repositories/car_repository.dart';

class CarRepositoryImpl implements CarRepository {
  final List<Car> _cars = [
    const Car(id: 1,  name: 'Toyota Avanza',     dailyPrice: 545000,  lateFeePerHour: 50000),
    const Car(id: 2,  name: 'Honda Brio',        dailyPrice: 495000,  lateFeePerHour: 40000),
    const Car(id: 3,  name: 'Daihatsu Sigra',    dailyPrice: 495000,  lateFeePerHour: 40000),
    const Car(id: 4,  name: 'Honda Mobilio',     dailyPrice: 545000,  lateFeePerHour: 50000),
    const Car(id: 5,  name: 'Honda HR-V',        dailyPrice: 695000,  lateFeePerHour: 60000),
    const Car(id: 6,  name: 'Honda Jazz',        dailyPrice: 645000,  lateFeePerHour: 60000),
    const Car(id: 7,  name: 'Toyota New Avanza', dailyPrice: 695000,  lateFeePerHour: 60000),
    const Car(id: 8,  name: 'Toyota New Innova', dailyPrice: 775000,  lateFeePerHour: 70000),
    const Car(id: 9,  name: 'Pajero Sport',      dailyPrice: 1900000, lateFeePerHour: 190000),
    const Car(id: 10, name: 'Fortuner',          dailyPrice: 1900000, lateFeePerHour: 190000),
  ];

  @override
  List<Car> getAllCars() {
    return List.unmodifiable(_cars);
  }

  @override
  void updateCar(Car car) {
    final index = _cars.indexWhere((c) => c.id == car.id);
    if (index != -1) {
      _cars[index] = car;
    }
  }
}