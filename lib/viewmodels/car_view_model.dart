import 'package:flutter/foundation.dart';
import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/domain/repositories/car_repository.dart';
import 'car_state.dart';

class CarViewModel extends ChangeNotifier {
  final CarRepository _repository;

  // View membaca state ini.
  CarState _state = const CarLoading();
  CarState get state => _state;

  CarViewModel(this._repository) {
    _load();
  }

  void loadCars() {
    _state = const CarLoading();
    notifyListeners();
    _load();
    notifyListeners();
  }

  void _load() {
    try {
      _state = CarLoaded(cars: _repository.getAllCars());
    } catch (_) {
      _state = const CarFailure('Gagal memuat daftar mobil. Silakan coba lagi.');
    }
  }

  void rentCar(int id) {
    final car = _findCar(id);

    if (car == null) {
      _state = const CarFailure('Mobil tidak ditemukan.');
      notifyListeners();
      return;
    }

    if (!car.isAvailable) {
      _state = CarFailure('${car.name} sedang disewa. Pilih mobil lain atau tunggu sampai kembali.');
      notifyListeners();
      return;
    }

    _repository.updateCar(car.copyWith(isAvailable: false));
    _load();
    notifyListeners();
  }

  void returnCar(int id) {
    final car = _findCar(id);

    if (car == null) {
      _state = const CarFailure('Mobil tidak ditemukan.');
      notifyListeners();
      return;
    }

    _repository.updateCar(car.copyWith(isAvailable: true));
    _load();
    notifyListeners();
  }

  // Menghitung total biaya
  int calculateTotal(Car car, {required int lateHours}) {
    final extraDays = lateHours ~/ 12;
    final rentalDays = 1 + extraDays;
    final rentalCost = car.dailyPrice * rentalDays;
    final lateFee = car.lateFeePerHour * lateHours;
    return rentalCost + lateFee;
  }

  Car? _findCar(int id) {
    for (final car in _repository.getAllCars()) {
      if (car.id == id) return car;
    }
    return null;
  }
}