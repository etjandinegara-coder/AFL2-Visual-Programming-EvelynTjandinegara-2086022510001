import 'package:flutter/foundation.dart';
import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/domain/repositories/car_repository.dart';

class CarViewModel extends ChangeNotifier {
  final CarRepository _repository;

  CarViewModel(this._repository);

  // ListCar yang ditampilkan View.
  List<Car> get cars => _repository.getAllCars();

  // errorMessage untuk ditampilkan ke user. Null berarti tidak ada error.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // rentCar berdasarkan id.
  void rentCar(int id) {
    final car = _findCar(id);

    if (car == null) {
      _errorMessage = 'Mobil tidak ditemukan.';
      notifyListeners();
      return;
    }

    if (!car.isAvailable) {
      _errorMessage = '${car.name} sedang disewa. Pilih mobil lain atau tunggu sampai kembali.';
      notifyListeners();
      return;
    }

    _repository.updateCar(car.copyWith(isAvailable: false));
    _errorMessage = null;
    notifyListeners();
  }

  // returnCar berdasarkan id.
  void returnCar(int id) {
    final car = _findCar(id);

    if (car == null) {
      _errorMessage = 'Mobil tidak ditemukan.';
      notifyListeners();
      return;
    }

    _repository.updateCar(car.copyWith(isAvailable: true));
    _errorMessage = null;
    notifyListeners();
  }

  // Mencari mobil berdasarkan id. Return null kalau tidak ada.
  Car? _findCar(int id) {
    for (final car in _repository.getAllCars()) {
      if (car.id == id) return car;
    }
    return null;
  }
}