import 'package:flutter_test/flutter_test.dart';
import 'package:rental_car/data/repositories/car_repository_implementation.dart';
import 'package:rental_car/viewmodels/car_view_model.dart';
import 'package:rental_car/main.dart';

void main() {
  testWidgets('daftar mobil tampil', (WidgetTester tester) async {
    final viewModel = CarViewModel(CarRepositoryImpl());

    await tester.pumpWidget(MyApp(viewModel: viewModel));

    expect(find.text('Toyota Avanza'), findsOneWidget);
  });
}