import 'dart:io';

class Contact {
  final String name;
  final String email;
  final String phone;
  final File? image;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.image,
  });

  // Turn Object -> JSON String
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imagePath': image?.path,
    };
  }

  // Turn JSON String -> Object
  // How to think about it: Use ?? (the "Otherwise" operator) to provide default values if data is missing.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? 'No Email',
      phone: json['phone'] ?? 'No Phone',
      image: json['imagePath'] != null ? File(json['imagePath']) : null,
    );
  }
}
