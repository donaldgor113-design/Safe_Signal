class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String? fcmToken;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.fcmToken,
  });
}
