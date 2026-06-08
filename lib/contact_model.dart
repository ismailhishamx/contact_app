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

  // Convert a Contact object into a Map (JSON)
  // How to think about it: We create a simple dictionary of strings so the computer can save it easily.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imagePath': image?.path, // We save the file path, not the actual file object
    };
  }

  // Create a Contact object from a Map (JSON)
  // How to think about it: We take the saved dictionary and rebuild the Contact object.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['imagePath'] != null ? File(json['imagePath']) : null,
    );
  }
}
