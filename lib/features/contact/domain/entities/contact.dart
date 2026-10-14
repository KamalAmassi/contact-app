class Contact {
  final int id;
  final String name;
  final String email;
  final String phone;

  const Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  Contact copyWith({int? id, String? name, String? email, String? phone}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}