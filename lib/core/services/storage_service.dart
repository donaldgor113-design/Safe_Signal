import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';

class StorageService {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  StorageService({
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  Future<String> uploadVideo(File videoFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          '${FirebaseConstants.alertsStoragePath}/$_userId/$timestamp.mp4';
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(technicalDetails: e.message);
    }
  }
}
