class UserModel {
  String username;
  String email;
  String firstName;
  String lastName;
  double walletBalance;
  String phoneNumber;
  String address;
  String nationalId;
  bool verified;
  String personalPhoto;
  String nationalIdPhoto;
  String licencePhoto;

  UserModel({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.walletBalance,
    required this.phoneNumber,
    required this.address,
    required this.nationalId,
    required this.verified,
    required this.personalPhoto,
    required this.nationalIdPhoto,
    required this.licencePhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      walletBalance: double.tryParse(json['wallet_balance']) ?? 0.0,
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      nationalId: json['national_id'] ?? '',
      verified: json['verified'] ?? false,
      personalPhoto: json['personal_photo'] ?? '',
      nationalIdPhoto: json['national_id_photo'] ?? '',
      licencePhoto: json['licence_photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'wallet_balance': walletBalance,
      'phone_number': phoneNumber,
      'address': address,
      'national_id': nationalId,
      'verified': verified,
      'personal_photo': personalPhoto,
      'national_id_photo': nationalIdPhoto,
      'licence_photo': licencePhoto,
    };
  }
}