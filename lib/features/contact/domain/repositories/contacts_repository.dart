import '../entities/contact.dart';

abstract class ContactsRepository {
  Future<List<Contact>> getContacts();
  Future<Contact> addContact(Contact contact);
  Future<Contact> updateContact(Contact contact);
  Future<void> deleteContact(int id);
}