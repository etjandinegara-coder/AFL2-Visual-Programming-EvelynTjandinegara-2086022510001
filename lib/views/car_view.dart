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

  // Alur pengembalian: tanya jam terlambat, tampilkan rincian, lalu konfirmasi.
  Future<void> _onReturn(BuildContext context, Car car) async {
    final lateHours = await showDialog<int>(
      context: context,
      builder: (_) => const _LateHoursDialog(),
    );
    if (lateHours == null || !context.mounted) return;

    final s = viewModel.returnSummary(car, lateHours: lateHours);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rincian ${car.name}'),
        content: Text(
          'Hari sewa: ${s.rentalDays}\n'
              'Biaya sewa: Rp ${s.rentalCost}\n'
              'Terlambat: $lateHours jam\n'
              'Denda: Rp ${s.lateFee}\n'
              'Total: Rp ${s.total}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bayar & kembalikan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      viewModel.returnCar(car.id);
    }
  }

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
                onPressed: () => _onReturn(context, car),
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

class _LateHoursDialog extends StatefulWidget {
  const _LateHoursDialog();

  @override
  State<_LateHoursDialog> createState() => _LateHoursDialogState();
}

class _LateHoursDialogState extends State<_LateHoursDialog> {
  final _controller = TextEditingController(text: '0');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Berapa jam terlambat?'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Jam terlambat'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final hours = int.tryParse(_controller.text.trim()) ?? 0;
            Navigator.pop(context, hours < 0 ? 0 : hours);
          },
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}