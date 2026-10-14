import 'package:contact_app/core/constant/AppSize.dart';
import 'package:contact_app/core/error/failure.dart';
import 'package:contact_app/core/theme/AppColors.dart';
import 'package:contact_app/features/contact/data/repositories/contacts_repository_impl.dart';
import 'package:contact_app/features/contact/data/services/contacts_service.dart';
import 'package:contact_app/features/contact/domain/entities/contact.dart';
import 'package:contact_app/features/contact/domain/usecases/add_contact.dart';
import 'package:contact_app/features/contact/domain/usecases/delete_contact.dart';
import 'package:contact_app/features/contact/domain/usecases/get_contacts.dart';
import 'package:contact_app/features/contact/domain/usecases/update_contact.dart';
import 'package:contact_app/features/contact/presentation/widget/contact_card.dart';
import 'package:contact_app/features/contact/presentation/widget/contact_form_sheet.dart';
import 'package:contact_app/features/contact/presentation/widget/contacts_state_views.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late final GetContacts _getContacts;
  late final AddContact _addContact;
  late final UpdateContact _updateContact;
  late final DeleteContact _deleteContact;

  late Future<void> _loadFuture;
  List<Contact> _contacts = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    final repo = ContactsRepositoryImpl(ContactsService(http.Client()));
    _getContacts = GetContacts(repo);
    _addContact = AddContact(repo);
    _updateContact = UpdateContact(repo);
    _deleteContact = DeleteContact(repo);
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final result = await _getContacts(null);
    _contacts = List<Contact>.from(result);
  }

  void _retry() => setState(() => _loadFuture = _load());

  Future<void> _onRefresh() async {
    try {
      await _load();
      if (mounted) setState(() {});
    } catch (e) {
      _snack(_msg(e));
    }
  }

  List<Contact> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q) ||
        c.phone.contains(q))
        .toList();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  String _msg(Object e) {
    debugPrint('ERROR: $e');
    return e is Failure ? e.message : 'حدث خطأ غير متوقع';
  }

  int get _nextLocalId {
    final maxId = _contacts.fold<int>(10, (m, c) => c.id > m ? c.id : m);
    return maxId + 1;
  }

  Future<void> _onAdd() async {
    final input = await showContactFormSheet(context);
    if (input == null) return;
    try {
      await _addContact(input);
      // السيرفر بيرجع نفس الـ id دايما، فبنعطي id محلي مميز
      setState(() => _contacts.add(input.copyWith(id: _nextLocalId)));
      _snack('تمت إضافة جهة الاتصال');
    } catch (e) {
      _snack(_msg(e));
    }
  }

  Future<void> _onEdit(Contact contact) async {
    final input = await showContactFormSheet(context, initial: contact);
    if (input == null) return;
    try {
      final updated = await _updateContact(input);
      final i = _contacts.indexWhere((c) => c.id == contact.id);
      if (i != -1) setState(() => _contacts[i] = updated);
      _snack('تم تعديل جهة الاتصال');
    } catch (e) {
      _snack(_msg(e));
    }
  }

  Future<bool> _confirmDelete(Contact contact) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${contact.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return false;

    try {
      await _deleteContact(contact.id);
      _snack('تم حذف جهة الاتصال');
      return true;
    } catch (e) {
      _snack(_msg(e));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdd,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('إضافة جهة'),
      ),
      body: Column(
        children: [
          _Header(
            count: _contacts.length,
            onChanged: (v) => setState(() => _query = v),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return ContactsErrorView(
                    message: _msg(snapshot.error!),
                    onRetry: _retry,
                  );
                }

                final items = _filtered;
                if (items.isEmpty) {
                  return ContactsEmptyView(isSearch: _query.isNotEmpty);
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.padding,
                      AppSizes.padding,
                      AppSizes.padding,
                      96,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final c = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(c.id),
                          direction: DismissDirection.horizontal,
                          background: const _DeleteBackground(
                            alignment: AlignmentDirectional.centerStart,
                          ),
                          secondaryBackground: const _DeleteBackground(
                            alignment: AlignmentDirectional.centerEnd,
                          ),
                          confirmDismiss: (_) => _confirmDelete(c),
                          onDismissed: (_) => setState(
                                () => _contacts.removeWhere((x) => x.id == c.id),
                          ),
                          child: ContactCard(
                            contact: c,
                            onEdit: () => _onEdit(c),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final ValueChanged<String> onChanged;

  const _Header({required this.count, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.padding,
            12,
            AppSizes.padding,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.contacts_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'دفتر جهات الاتصال',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$count جهة اتصال',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الإيميل أو الجوال',
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  final AlignmentGeometry alignment;
  const _DeleteBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'حذف',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}