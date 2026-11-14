import 'package:equatable/equatable.dart';
import 'package:rental_car/domain/models/car.dart';

sealed class CarState extends Equatable {
  const CarState();
}

final class CarLoading extends CarState {
  const CarLoading();

  @override
  List<Object?> get props => [];
}

final class CarLoaded extends CarState {
  final List<Car> cars;
  final String? message;

  const CarLoaded({required this.cars, this.message});

  @override
  List<Object?> get props => [cars, message];
}

final class CarFailure extends CarState {
  final String message;

  const CarFailure(this.message);

  @override
  List<Object?> get props => [message];
}