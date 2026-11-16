import 'package:equatable/equatable.dart';

class Car extends Equatable {
  final int id;
  final String name;
  final int dailyPrice;
  final int lateFeePerHour;
  final bool isAvailable;

  const Car({
    required this.id,
    required this.name,
    required this.dailyPrice,
    required this.lateFeePerHour,
    this.isAvailable = true,
  });

  Car copyWith({bool? isAvailable}) {
    return Car(
      id: id,
      name: name,
      dailyPrice: dailyPrice,
      lateFeePerHour: lateFeePerHour,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [id, name, dailyPrice, lateFeePerHour, isAvailable];
}