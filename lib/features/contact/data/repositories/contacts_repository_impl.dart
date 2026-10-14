import 'package:contact_app/features/contact/data/model/contact_model.dart';

import '../../domain/entities/contact.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../services/contacts_service.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsService service;
  ContactsRepositoryImpl(this.service);
  static const _serverMaxId = 10;

  @override
  Future<List<Contact>> getContacts() => service.fetchContacts();

  @override
  Future<Contact> addContact(Contact contact) =>
      service.createContact(ContactModel.fromEntity(contact));

  @override
  Future<Contact> updateContact(Contact contact) async {
    if (contact.id > _serverMaxId) return contact;
    return service.updateContact(ContactModel.fromEntity(contact));
  }

  @override
  Future<void> deleteContact(int id) async {
    if (id > _serverMaxId) return;
    await service.deleteContact(id);
  }
}