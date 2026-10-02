import 'package:supabase_flutter/supabase_flutter.dart';

/// A server receipt acknowledges a request, never claims completed erasure.
class DeletionReceipt {
  const DeletionReceipt({required this.id, required this.dueAt});
  final String id;
  final DateTime dueAt;
}

abstract interface class AccountDeletionAccess {
  Future<bool> isAvailable();
  Future<DeletionReceipt?> pendingRequest();
  Future<DeletionReceipt> requestDeletion();
}

class SupabaseAccountDeletion implements AccountDeletionAccess {
  SupabaseAccountDeletion(this.client) : _owner = client.auth.currentUser?.id;
  final SupabaseClient client;
  final String? _owner;

  void _checkOwner() {
    if (_owner == null || _owner != client.auth.currentUser?.id) {
      throw StateError('Account changed. Reopen account deletion.');
    }
  }

  @override
  Future<bool> isAvailable() async {
    _checkOwner();
    return await client.rpc('luma_account_deletion_available') == true;
  }

  @override
  Future<DeletionReceipt?> pendingRequest() async {
    _checkOwner();
    final data = await client.rpc('luma_my_account_deletion_request');
    _checkOwner();
    return data == null ? null : _receipt(data);
  }

  @override
  Future<DeletionReceipt> requestDeletion() async {
    _checkOwner();
    // Never accept a client-supplied target user or email. The RPC derives both.
    final data = await client.rpc(
      'luma_request_account_deletion',
      params: {'confirmation': 'DELETE MY ACCOUNT'},
    );
    _checkOwner();
    return _receipt(data);
  }

  DeletionReceipt _receipt(dynamic data) {
    if (data is! Map ||
        data['status'] != 'pending' ||
        data['request_id'] is! String ||
        data['due_at'] is! String) {
      throw StateError('No deletion request receipt was returned');
    }
    return DeletionReceipt(
      id: data['request_id'] as String,
      dueAt: DateTime.parse(data['due_at'] as String),
    );
  }
}
