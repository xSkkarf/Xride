class UserModel {
  int id;
  String username;
  String email;
  String firstName;
  String lastName;
  double walletBalance;
  String phoneNumber;
  String address;
  String nationalId;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.walletBalance,
    required this.phoneNumber,
    required this.address,
    required this.nationalId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      walletBalance: double.tryParse(json['wallet_balance']) ?? 0.0,
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      nationalId: json['national_id'] ?? '',
    );
  }
}