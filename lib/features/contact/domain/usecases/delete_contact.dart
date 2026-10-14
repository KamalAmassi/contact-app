import 'package:contact_app/core/usecase/usecase.dart';

import '../repositories/contacts_repository.dart';

class DeleteContact implements UseCase<void, int> {
  final ContactsRepository repository;
  DeleteContact(this.repository);

  @override
  Future<void> call(int params) => repository.deleteContact(params);
}