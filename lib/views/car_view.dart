import 'package:flutter/material.dart';
import 'package:rental_car/domain/models/car.dart';
import 'package:rental_car/viewmodels/car_state.dart';
import 'package:rental_car/viewmodels/car_view_model.dart';

class CarView extends StatelessWidget {
  final CarViewModel viewModel;

  const CarView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rental Mobil')),
      // ListenableBuilder menggambar ulang layar setiap kali ViewModel memanggil notifyListeners().
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final state = viewModel.state;

          // View hanya memilih widget sesuai kondisi. Karena CarState sealed, semua kondisi wajib ditangani.
          return switch (state) {
            CarLoading() => const Center(child: CircularProgressIndicator()),
            CarLoaded(:final cars) => _CarList(cars: cars, viewModel: viewModel),
            CarFailure(:final message) => _ErrorView(
              message: message,
              onRetry: viewModel.loadCars,
            ),
          };
        },
      ),
    );
  }
}

class _CarList extends StatelessWidget {
  final List<Car> cars;
  final CarViewModel viewModel;

  const _CarList({required this.cars, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return ListTile(
          title: Text(car.name),
          subtitle: Text(
            'Rp ${car.dailyPrice}/hari · ${car.isAvailable ? 'Tersedia' : 'Disewa'}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => viewModel.rentCar(car.id),
                child: const Text('Sewa'),
              ),
              TextButton(
                onPressed: () => viewModel.returnCar(car.id),
                child: const Text('Kembali'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}