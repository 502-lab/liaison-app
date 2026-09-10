import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:liaison_app/core/storage/token_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage_provider.g.dart';

@riverpod
TokenStorage tokenStorage(Ref ref) {
  return const SecureTokenStorage(FlutterSecureStorage());
}
