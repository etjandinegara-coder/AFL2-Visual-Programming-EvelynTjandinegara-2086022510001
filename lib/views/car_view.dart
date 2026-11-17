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
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final state = viewModel.state;

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
      padding: const EdgeInsets.all(16),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return _CarCard(
          car: car,
          onRent: () => viewModel.rentCar(car.id),
          onReturn: () => _onReturn(context, car),
        );
      },
    );
  }
}

class _CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onRent;
  final VoidCallback onReturn;

  const _CarCard({
    required this.car,
    required this.onRent,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final available = car.isAvailable;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Rp ${car.dailyPrice}/hari', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: available ? colors.primaryContainer : colors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    available ? 'Tersedia' : 'Disewa',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: available ? colors.onPrimaryContainer : colors.onErrorContainer,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: available ? onRent : null,
                  child: const Text('Sewa'),
                ),
                TextButton(
                  onPressed: onReturn,
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: colors.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
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
          // View hanya mengirim teks mentah. Parsing dilakukan ViewModel.
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}