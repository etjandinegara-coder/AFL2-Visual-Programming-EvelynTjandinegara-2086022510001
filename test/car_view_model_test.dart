import 'package:flutter_test/flutter_test.dart';
import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/domain/repositories/car_repository.dart';
import 'package:rental_car/viewmodels/car_state.dart';
import 'package:rental_car/viewmodels/car_view_model.dart';

// Repository palsu di memori, supaya tes tidak butuh penyimpanan asli.
class FakeCarRepository implements CarRepository {
  final List<Car> cars;

  FakeCarRepository(this.cars);

  @override
  Future<List<Car>> getAllCars() async => List.of(cars);

  @override
  Future<void> updateCar(Car car) async {
    final i = cars.indexWhere((c) => c.id == car.id);
    if (i != -1) cars[i] = car;
  }
}

final avanza = Car(id: 1, name: 'Toyota Avanza', dailyPrice: 545000, lateFeePerHour: 50000);

void main() {
  // Tes 1: rumus denda dan hari sewa
  group('returnSummary', () {
    late CarViewModel vm;

    setUp(() {
      vm = CarViewModel(FakeCarRepository([avanza]));
    });

    test('0 jam terlambat: 1 hari, tanpa denda', () {
      final s = vm.returnSummary(avanza, lateHours: 0);
      expect(s.total, 545000);
    });

    test('11 jam terlambat: masih 1 hari, denda 11 jam', () {
      final s = vm.returnSummary(avanza, lateHours: 11);
      expect(s.rentalDays, 1);
      expect(s.total, 545000 + 50000 * 11);
    });

    test('12 jam terlambat: 2 hari + denda 12 jam = 1.690.000', () {
      final s = vm.returnSummary(avanza, lateHours: 12);
      expect(s.rentalDays, 2);
      expect(s.total, 1690000);
    });

    test('24 jam terlambat: 3 hari + denda 24 jam = 2.835.000', () {
      final s = vm.returnSummary(avanza, lateHours: 24);
      expect(s.rentalDays, 3);
      expect(s.total, 2835000);
    });
  });

  // Tes 2: sewa
  group('rentCar', () {
    test('mobil tersedia berubah menjadi disewa', () async {
      final repo = FakeCarRepository([avanza]);
      final vm = CarViewModel(repo);
      await vm.rentCar(1);

      final state = vm.state as CarLoaded;
      expect(state.cars.first.isAvailable, false);
    });

    test('mobil yang sudah disewa menghasilkan Failure', () async {
      final repo = FakeCarRepository([avanza]);
      final vm = CarViewModel(repo);
      await vm.rentCar(1);
      await vm.rentCar(1);

      expect(vm.state, isA<CarFailure>());
    });
  });

  // Tes 3: kembali
  group('returnCar', () {
    test('mobil yang disewa kembali tersedia', () async {
      final repo = FakeCarRepository([avanza]);
      final vm = CarViewModel(repo);
      await vm.rentCar(1);
      await vm.returnCar(1);

      final state = vm.state as CarLoaded;
      expect(state.cars.first.isAvailable, true);
    });
  });
}