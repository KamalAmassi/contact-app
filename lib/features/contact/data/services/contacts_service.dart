import 'dart:convert';

import 'package:contact_app/core/error/failure.dart';
import 'package:contact_app/features/contact/data/model/contact_model.dart';
import 'package:http/http.dart' as http;

class ContactsService {
  final http.Client client;
  ContactsService(this.client);

  static const _baseUrl = 'https://jsonplaceholder.typicode.com/users';
  static const _headers = {'Content-Type': 'application/json; charset=UTF-8'};

  Future<List<ContactModel>> fetchContacts() async {
    try {
      final res = await client.get(Uri.parse(_baseUrl));
      if (res.statusCode != 200) {
        throw const Failure('فشل تحميل جهات الاتصال');
      }
      final list = jsonDecode(res.body) as List;
      return list
          .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure('تعذر الاتصال بالخادم، تحقق من الإنترنت');
    }
  }

  Future<ContactModel> createContact(ContactModel contact) async {
    try {
      final res = await client.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(contact.toJson()),
      );
      if (res.statusCode != 201) {
        throw const Failure('فشلت إضافة جهة الاتصال');
      }
      return ContactModel.fromJson(jsonDecode(res.body));
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure('تعذر الاتصال بالخادم، تحقق من الإنترنت');
    }
  }

  Future<ContactModel> updateContact(ContactModel contact) async {
    try {
      final res = await client.patch(
        Uri.parse('$_baseUrl/${contact.id}'),
        headers: _headers,
        body: jsonEncode(contact.toJson()),
      );
      if (res.statusCode != 200) {
        throw const Failure('فشل تعديل جهة الاتصال');
      }
      return ContactModel.fromJson(jsonDecode(res.body));
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure('تعذر الاتصال بالخادم، تحقق من الإنترنت');
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      final res = await client.delete(Uri.parse('$_baseUrl/$id'));
      if (res.statusCode != 200) {
        throw const Failure('فشل حذف جهة الاتصال');
      }
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure('تعذر الاتصال بالخادم، تحقق من الإنترنت');
    }
  }
}