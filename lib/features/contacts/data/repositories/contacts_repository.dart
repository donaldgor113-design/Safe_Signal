import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_signal/core/constants/firebase_constants.dart';
import 'package:safe_signal/core/errors/exceptions.dart';
import 'package:safe_signal/features/contacts/data/models/contact_model.dart';

class ContactsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ContactsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _contactsRef => _firestore
      .collection(FirebaseConstants.contactsCollection)
      .doc(_userId)
      .collection(FirebaseConstants.contactItemsSubcollection);

  Stream<List<ContactModel>> watchContacts() {
    return _contactsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ContactModel.fromFirestore(doc)).toList());
  }

  Future<List<ContactModel>> getContacts() async {
    try {
      final snapshot = await _contactsRef.get();
      return snapshot.docs
          .map((doc) => ContactModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }

  Future<ContactModel?> getContact(String contactId) async {
    try {
      final doc = await _contactsRef.doc(contactId).get();
      if (!doc.exists) return null;
      return ContactModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }

  Future<String> addContact(ContactModel contact) async {
    try {
      final doc = await _contactsRef.add(contact.toMap());
      return doc.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      await _contactsRef.doc(contact.id).update(contact.toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _contactsRef.doc(contactId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    } catch (e) {
      throw FirestoreException(technicalDetails: e.toString());
    }
  }
}
