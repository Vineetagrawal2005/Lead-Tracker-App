/// Hive + SharedPreferences wrapper.
///
/// UI never calls Hive or SharedPreferences directly - all persistence goes
/// through this service. Leads and notes are scoped to the logged-in user by
/// storing [userId] on each record and filtering on read.
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/lead_model.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Box? _usersBox;
  Box? _leadsBox;
  Box? _notesBox;
  SharedPreferences? _prefs;

  /// Initialize Hive and SharedPreferences. Must be called before [runApp].
  Future<void> init() async {
    await Hive.initFlutter();
    _usersBox = await Hive.openBox(kUsersBox);
    _leadsBox = await Hive.openBox(kLeadsBox);
    _notesBox = await Hive.openBox(kNotesBox);
    _prefs = await SharedPreferences.getInstance();
  }

  Box get usersBox => _usersBox!;
  Box get leadsBox => _leadsBox!;
  Box get notesBox => _notesBox!;
  SharedPreferences get prefs => _prefs!;

  // ---- Users ----

  Future<void> saveUser(UserModel user) async {
    await usersBox.put(user.id, user.toMap());
  }

  UserModel? getUser(String id) {
    final map = usersBox.get(id);
    if (map == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(map as Map));
  }

  UserModel? getUserByEmail(String email) {
    final lower = email.toLowerCase();
    for (final key in usersBox.keys) {
      final map = usersBox.get(key);
      if (map != null && (map as Map)['email'] == lower) {
        return UserModel.fromMap(Map<String, dynamic>.from(map));
      }
    }
    return null;
  }

  // ---- Leads (scoped by userId) ----

  Future<void> saveLead(LeadModel lead) async {
    await leadsBox.put(lead.id, lead.toMap());
  }

  List<LeadModel> getLeadsForUser(String userId) {
    final list = <LeadModel>[];
    for (final key in leadsBox.keys) {
      final map = leadsBox.get(key);
      if (map == null) continue;
      final lead = LeadModel.fromMap(Map<String, dynamic>.from(map as Map));
      if (lead.userId == userId) {
        list.add(lead);
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> deleteLead(String id) async {
    await leadsBox.delete(id);
  }

  // ---- Notes (scoped by leadId) ----

  Future<void> saveNote(NoteModel note) async {
    await notesBox.put(note.id, note.toMap());
  }

  List<NoteModel> getNotesForLead(String leadId) {
    final list = <NoteModel>[];
    for (final key in notesBox.keys) {
      final map = notesBox.get(key);
      if (map == null) continue;
      final note = NoteModel.fromMap(Map<String, dynamic>.from(map as Map));
      if (note.leadId == leadId) {
        list.add(note);
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  Future<void> clearAllDataForUser(String userId) async {
    // Collect lead IDs first so we can remove their notes.
    final leadIds = <String>{};
    for (final key in leadsBox.keys.toList()) {
      final map = leadsBox.get(key);
      if (map == null) continue;
      final lead = LeadModel.fromMap(Map<String, dynamic>.from(map as Map));
      if (lead.userId == userId) {
        leadIds.add(lead.id);
        await leadsBox.delete(key);
      }
    }
    for (final key in notesBox.keys.toList()) {
      final map = notesBox.get(key);
      if (map == null) continue;
      final note = NoteModel.fromMap(Map<String, dynamic>.from(map as Map));
      if (leadIds.contains(note.leadId)) {
        await notesBox.delete(key);
      }
    }
  }

  // ---- Session (SharedPreferences) ----

  Future<void> saveSession({
    required bool isLoggedIn,
    required String userId,
    required bool rememberMe,
  }) async {
    await prefs.setBool(kIsLoggedInKey, isLoggedIn);
    await prefs.setString(kCurrentUserIdKey, userId);
    await prefs.setBool(kRememberMeKey, rememberMe);
  }

  bool get isLoggedIn => prefs.getBool(kIsLoggedInKey) ?? false;
  String? get currentUserId => prefs.getString(kCurrentUserIdKey);
  bool get rememberMe => prefs.getBool(kRememberMeKey) ?? false;

  Future<void> clearSession() async {
    await prefs.remove(kIsLoggedInKey);
    await prefs.remove(kCurrentUserIdKey);
    await prefs.remove(kRememberMeKey);
  }
}
