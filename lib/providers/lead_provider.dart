/// Lead provider.
///
/// State: [allLeads], [status], [errorMessage], [searchQuery],
/// [selectedFilter], [sortOption].
/// Getters: [filteredLeads], [totalCount], [countByStatus], [conversionRate],
/// [recentLeads].
/// Methods: [loadLeads], [refreshFromApi], [addLead], [updateLead],
/// [deleteLead], [undoDeleteLead], [changeStatus], [addNote], [deleteNote],
/// [notesFor], [setSearch], [setFilter], [setSort].
///
/// Every change persists to Hive immediately and calls [notifyListeners].
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../models/lead_model.dart';
import '../models/note_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum LeadListStatus { loading, loaded, error }

class LeadProvider extends ChangeNotifier {
  LeadProvider(this._storage, this._api);

  final StorageService _storage;
  final ApiService _api;

  List<LeadModel> _allLeads = [];
  LeadListStatus _status = LeadListStatus.loading;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All' | 'New' | 'Contacted' | 'Converted'
  String _sortOption =
      'Newest first'; // 'Newest first' | 'Oldest first' | 'Name A-Z'

  LeadModel? _deletedForUndo;
  Timer? _undoTimer;

  List<LeadModel> get allLeads => _allLeads;
  LeadListStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  String get sortOption => _sortOption;

  /// Leads after applying search + filter + sort.
  List<LeadModel> get filteredLeads {
    var list = List<LeadModel>.from(_allLeads);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((lead) {
        return lead.name.toLowerCase().contains(q) ||
            lead.phone.contains(q) ||
            lead.email.toLowerCase().contains(q) ||
            lead.company.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedFilter != 'All') {
      list = list.where((lead) => lead.status == _selectedFilter).toList();
    }

    switch (_sortOption) {
      case 'Newest first':
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'Oldest first':
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'Name A-Z':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  int get totalCount => _allLeads.length;

  int countByStatus(String status) =>
      _allLeads.where((lead) => lead.status == status).length;

  double get conversionRate {
    if (_allLeads.isEmpty) return 0;
    return countByStatus('Converted') / _allLeads.length;
  }

  List<LeadModel> get recentLeads {
    final list = List<LeadModel>.from(_allLeads)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list.take(kRecentLeadsLimit).toList();
  }

  /// Notes for [leadId], newest first.
  List<NoteModel> notesFor(String leadId) => _storage.getNotesForLead(leadId);

  String? get currentUserId => _storage.currentUserId;

  void _setStatus(LeadListStatus value) {
    _status = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> _persist() async {
    for (final lead in _allLeads) {
      await _storage.saveLead(lead);
    }
  }

  /// Load leads: local first, then API if empty (first launch after login).
  Future<void> loadLeads() async {
    final userId = currentUserId;
    if (userId == null) return;

    _setStatus(LeadListStatus.loading);
    _setError(null);
    _allLeads = _storage.getLeadsForUser(userId);

    if (_allLeads.isNotEmpty) {
      _setStatus(LeadListStatus.loaded);
      return;
    }

    // First launch: load sample data from the API.
    try {
      await _fetchAndMerge(userId, initialLoad: true);
    } on ApiException catch (e) {
      _setError(e.message);
      _setStatus(LeadListStatus.error);
    } catch (_) {
      _setError('Could not load leads. Please try again later.');
      _setStatus(LeadListStatus.error);
    }
  }

  /// Re-fetch from the API and merge: add only new leads (dedupe by email),
  /// never overwrite user-created or edited leads. Returns true on success.
  Future<bool> refreshFromApi() async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _fetchAndMerge(userId, initialLoad: false);
      _setError(null);
      return true;
    } on ApiException catch (e) {
      // Local leads (if any) are still shown. The caller surfaces the error.
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Could not refresh leads. Please try again later.');
      return false;
    }
  }

  Future<void> _fetchAndMerge(
    String userId, {
    required bool initialLoad,
  }) async {
    final apiLeads = await _api.fetchLeads(userId: userId);
    final existingEmails = _allLeads.map((l) => l.email.toLowerCase()).toSet();
    final now = DateTime.now();

    for (final lead in apiLeads) {
      if (existingEmails.contains(lead.email.toLowerCase())) continue;
      _allLeads.add(
        lead.copyWith(userId: userId, createdAt: now, updatedAt: now),
      );
      existingEmails.add(lead.email.toLowerCase());
    }

    await _persist();
    _setStatus(LeadListStatus.loaded);
    if (initialLoad) _setError(null);
  }

  /// Add a new lead. Returns false if a lead with this phone already exists.
  Future<bool> addLead(LeadModel lead) async {
    final userId = currentUserId;
    if (userId == null) return false;
    if (_hasLeadWithPhone(lead.phone, excludeId: null)) {
      _setError('A lead with this phone number already exists.');
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final newLead = lead.copyWith(
      id: const Uuid().v4(),
      userId: userId,
      isFromApi: false,
      createdAt: lead.createdAt == DateTime.fromMillisecondsSinceEpoch(0)
          ? now
          : (lead.id.isEmpty ? now : lead.createdAt),
      updatedAt: now,
    );
    _allLeads.add(newLead);
    await _persist();
    _setError(null);
    notifyListeners();
    return true;
  }

  /// Update an existing lead.
  Future<void> updateLead(LeadModel lead) async {
    final index = _allLeads.indexWhere((l) => l.id == lead.id);
    if (index == -1) return;
    _allLeads[index] = lead.copyWith(updatedAt: DateTime.now());
    await _persist();
    notifyListeners();
  }

  /// Delete a lead with undo support. The lead is kept for a short window so
  /// it can be restored via [undoDeleteLead].
  Future<void> deleteLead(String id) async {
    final index = _allLeads.indexWhere((l) => l.id == id);
    if (index == -1) return;
    _deletedForUndo = _allLeads.removeAt(index);
    await _storage.deleteLead(id);
    _startUndoTimer();
    notifyListeners();
  }

  /// Restore the most recently deleted lead (undo). Returns true if restored.
  Future<bool> undoDeleteLead() async {
    final lead = _deletedForUndo;
    if (lead == null) return false;
    _undoTimer?.cancel();
    _deletedForUndo = null;
    _allLeads.add(lead);
    await _storage.saveLead(lead);
    notifyListeners();
    return true;
  }

  void _startUndoTimer() {
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 4), () {
      _deletedForUndo = null;
      _undoTimer = null;
    });
  }

  /// Change a lead's status and update [updatedAt].
  Future<void> changeStatus(String leadId, String status) async {
    final index = _allLeads.indexWhere((l) => l.id == leadId);
    if (index == -1) return;
    _allLeads[index] = _allLeads[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  /// Add a note to a lead. Newest first.
  Future<void> addNote(String leadId, String text) async {
    final note = NoteModel(
      id: const Uuid().v4(),
      leadId: leadId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    await _storage.saveNote(note);
    notifyListeners();
  }

  /// Delete a note.
  Future<void> deleteNote(String noteId) async {
    await _storage.deleteNote(noteId);
    notifyListeners();
  }

  bool _hasLeadWithPhone(String phone, {String? excludeId}) {
    return _allLeads.any((l) {
      if (excludeId != null && l.id == excludeId) return false;
      return l.phone == phone;
    });
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSort(String option) {
    _sortOption = option;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears all leads/notes for the current user and reloads sample data from
  /// the API.
  Future<void> clearAllAndReload() async {
    final userId = currentUserId;
    if (userId == null) return;
    await _storage.clearAllDataForUser(userId);
    _allLeads = [];
    _setError(null);
    notifyListeners();
    await loadLeads();
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    super.dispose();
  }
}
