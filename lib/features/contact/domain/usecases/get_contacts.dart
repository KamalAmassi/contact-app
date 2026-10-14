import 'package:contact_app/core/usecase/usecase.dart';

import '../entities/contact.dart';
import '../repositories/contacts_repository.dart';

class GetContacts implements UseCase<List<Contact>, void> {
  final ContactsRepository repository;
  GetContacts(this.repository);

  @override
  Future<List<Contact>> call(void params) => repository.getContacts();
}