import 'package:equatable/equatable.dart';

class UpdateEntity extends Equatable {
  final String? userId;
  final String? name;
  final String? email;
  // final String? phoneNumber;
  final String? profilePicture;
  final DateTime? updatedAt;

  const UpdateEntity({
    this.userId,
    this.name,
    this.email,
    // this.phoneNumber,
    this.profilePicture,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    // phoneNumber,
    profilePicture,
    updatedAt,
  ];
}
