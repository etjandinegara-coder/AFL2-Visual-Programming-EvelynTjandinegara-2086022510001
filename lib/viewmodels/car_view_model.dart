import 'package:flutter/foundation.dart';
import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/domain/repositories/car_repository.dart';
import 'car_state.dart';

class CarViewModel extends ChangeNotifier {
  final CarRepository _repository;

  bool _disposed = false;

  CarState _state = const CarLoading();
  CarState get state => _state;

  CarViewModel(this._repository) {
    loadCars();
  }

  Future<void> loadCars() async {
    _emit(const CarLoading());
    try {
      final cars = await _repository.getAllCars();
      _emit(CarLoaded(cars: cars));
    } catch (_) {
      _emit(const CarFailure('Gagal memuat daftar mobil. Silakan coba lagi.'));
    }
  }

  Future<void> rentCar(int id) async {
    final car = await _findCar(id);

    if (car == null) {
      _emit(const CarFailure('Mobil tidak ditemukan.'));
      return;
    }

    if (!car.isAvailable) {
      _emit(CarFailure(
        '${car.name} sedang disewa. Pilih mobil lain atau tunggu sampai kembali.',
      ));
      return;
    }

    await _repository.updateCar(car.copyWith(isAvailable: false));
    await loadCars();
  }

  Future<void> returnCar(int id) async {
    final car = await _findCar(id);

    if (car == null) {
      _emit(const CarFailure('Mobil tidak ditemukan.'));
      return;
    }

    await _repository.updateCar(car.copyWith(isAvailable: true));
    await loadCars();
  }

  ({int rentalDays, int rentalCost, int lateFee, int total}) returnSummary(
      Car car, {
        required int lateHours,
      }) {
    final rentalDays = 1 + lateHours ~/ 12; // setiap 12 jam terlambat = 1 hari tambahan
    final rentalCost = car.dailyPrice * rentalDays;
    final lateFee = car.lateFeePerHour * lateHours;
    return (
    rentalDays: rentalDays,
    rentalCost: rentalCost,
    lateFee: lateFee,
    total: rentalCost + lateFee,
    );
  }

  int calculateTotal(Car car, {required int lateHours}) {
    return returnSummary(car, lateHours: lateHours).total;
  }

  Future<Car?> _findCar(int id) async {
    final cars = await _repository.getAllCars();
    for (final car in cars) {
      if (car.id == id) return car;
    }
    return null;
  }

  void _emit(CarState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}