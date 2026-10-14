import '../../domain/entities/contact.dart';

class ContactModel extends Contact {
   ContactModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  factory ContactModel.fromEntity(Contact c) => ContactModel(
    id: c.id,
    name: c.name,
    email: c.email,
    phone: c.phone,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
  };
}