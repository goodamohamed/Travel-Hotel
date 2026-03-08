import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getDownloadUrl(String path) async {
    final ref = _storage.ref(path);
    return ref.getDownloadURL();
  }
}

