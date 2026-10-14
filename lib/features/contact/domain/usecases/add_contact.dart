import 'package:contact_app/core/usecase/usecase.dart';

import '../entities/contact.dart';
import '../repositories/contacts_repository.dart';

class AddContact implements UseCase<Contact, Contact> {
  final ContactsRepository repository;
  AddContact(this.repository);

  @override
  Future<Contact> call(Contact params) => repository.addContact(params);
}