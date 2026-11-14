/// Fetches realistic sample leads from randomuser.me and maps them to [LeadModel].
///
/// All HTTP code lives here. The UI never calls http directly - it goes through
/// the provider, which converts typed [ApiException]s into user-friendly
/// messages.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../models/lead_model.dart';

/// Typed exception thrown by [ApiService] so the provider can convert it to a
/// user-friendly message. Never raw exceptions to the user.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Uuid _uuid = const Uuid();
  final int _random = DateTime.now().millisecondsSinceEpoch % 100;

  /// Fetch [kApiResults] Indian leads from randomuser.me with a 10s timeout.
  Future<List<LeadModel>> fetchLeads({required String userId}) async {
    final url = Uri.parse(
      '$kApiBaseUrl?results=$kApiResults&nat=in&seed=$kApiSeed',
    );
    try {
      final response = await _client.get(url).timeout(kApiTimeout);
      if (response.statusCode != 200) {
        throw ApiException('Server returned status ${response.statusCode}.');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      final now = DateTime.now();

      return results.asMap().entries.map((entry) {
        final index = entry.key;
        final person = entry.value as Map<String, dynamic>;
        return _mapToLead(person, userId, now, index);
      }).toList();
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } catch (_) {
      throw const ApiException('Could not load leads. Please try again later.');
    }
  }

  LeadModel _mapToLead(
    Map<String, dynamic> person,
    String userId,
    DateTime now,
    int index,
  ) {
    final nameMap = person['name'] as Map? ?? {};
    final first = (nameMap['first'] as String?) ?? '';
    final last = (nameMap['last'] as String?) ?? '';
    final fullName = '$first $last'.trim();

    final rawPhone = (person['phone'] as String?) ?? '';
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    // Take the last 10 digits if longer.
    final phone = digits.length > 10
        ? digits.substring(digits.length - 10)
        : digits;

    final email = (person['email'] as String?) ?? '';
    final photoUrl = (person['picture'] as Map? ?? {})['medium'] as String?;

    final company = kIndianCompanies[index % kIndianCompanies.length];
    final source = kLeadSources[index % kLeadSources.length];
    // Weighted: New 50%, Contacted 30%, Converted 20%.
    final statusRoll = (_random + index) % 100;
    final status = statusRoll < 50
        ? 'New'
        : statusRoll < 80
        ? 'Contacted'
        : 'Converted';

    final createdAt = now.subtract(const Duration(days: 6));
    return LeadModel(
      id: _uuid.v4(),
      userId: userId,
      name: fullName,
      phone: phone,
      email: email,
      company: company,
      source: source,
      status: status,
      photoUrl: photoUrl,
      isFromApi: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}
