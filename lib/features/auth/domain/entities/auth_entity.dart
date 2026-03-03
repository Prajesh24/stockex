import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String name;              // Changed from fullName to name
  final String email;
  final String? password;
  final String? imageUrl;         // Changed from profilePicture to imageUrl
  final String? role;

  const AuthEntity({
    this.authId,
    required this.name,           // Changed from fullName
    required this.email,
    this.password,
    this.imageUrl,                // Changed from profilePicture
    this.role = 'user',
  });

  @override
  List<Object?> get props => [
        authId,
        name,
        email,
        password,
        imageUrl,
        role,
      ];
}