class UserEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool isAdmin;
  final String? photoUrl;
  final bool phoneVerified;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.isAdmin = false,
    this.photoUrl,
    this.phoneVerified = false,
  });
}
