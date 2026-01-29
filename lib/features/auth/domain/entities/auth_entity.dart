import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;

 const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });


  @override
  // TODO: implement props
  List<Object?> get props => [
        authId,
        fullName,
        email,
        phoneNumber,
        password,
        confirmPassword,
        profilePicture,
  ];
}
