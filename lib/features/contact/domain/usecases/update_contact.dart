import 'package:contact_app/core/usecase/usecase.dart';
import '../entities/contact.dart';
import '../repositories/contacts_repository.dart';

class UpdateContact implements UseCase<Contact, Contact> {
  final ContactsRepository repository;
  UpdateContact(this.repository);

  @override
  Future<Contact> call(Contact params) => repository.updateContact(params);
}