import 'package:flutter/material.dart';
import 'package:rental_car/data/repositories/car_repository_implementation.dart';
import 'package:rental_car/viewmodels/car_view_model.dart';
import 'package:rental_car/views/car_view.dart';

void main() {
  final repository = CarRepositoryImpl();
  final viewModel = CarViewModel(repository);

  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  final CarViewModel viewModel;

  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: CarView(viewModel: viewModel),
    );
  }
}