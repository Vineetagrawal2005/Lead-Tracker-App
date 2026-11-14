/// Core constants for the Lead Tracker app.
///
/// Box names for Hive, keys for SharedPreferences, the API base URL and the
/// lead statuses are all defined here so they can be changed in one place.

library;

/// Hive box names.
const String kUsersBox = 'users';
const String kLeadsBox = 'leads';
const String kNotesBox = 'notes';

/// SharedPreferences keys.
const String kIsLoggedInKey = 'isLoggedIn';
const String kCurrentUserIdKey = 'currentUserId';
const String kRememberMeKey = 'rememberMe';

/// Public API used to load realistic sample leads (Indian nationals).
const String kApiBaseUrl = 'https://randomuser.me/api/';
const String kApiSeed = 'leadtracker';
const int kApiResults = 30;
const Duration kApiTimeout = Duration(seconds: 10);

/// Lead statuses (and their display colors are in [theme.dart]).
const List<String> kLeadStatuses = ['New', 'Contacted', 'Converted'];

/// Lead sources.
const List<String> kLeadSources = [
  'Website',
  'Referral',
  'Cold Call',
  'Social Media',
  'Walk-in',
  'Other',
];

/// Indian business names used to generate a stable company per API lead.
final List<String> kIndianCompanies = [
  'Tata Consultancy Services',
  'Reliance Industries',
  'Infosys',
  'HDFC Bank',
  'ICICI Bank',
  'Wipro',
  'Larsen & Toubro',
  'Bharti Airtel',
  'State Bank of India',
  'Mahindra & Mahindra',
  'Hindustan Unilever',
  'Bajaj Auto',
  'Asian Paints',
  'Maruti Suzuki',
  'Sun Pharma',
];

/// Default page size / limits.
const int kRecentLeadsLimit = 5;
const int kMaxNoteLength = 500;

/// Named routes used by [core/routes.dart].
const String kRouteSplash = '/';
const String kRouteLogin = '/login';
const String kRouteSignup = '/signup';
const String kRouteMainShell = '/main';
const String kRouteDashboard = '/dashboard';
const String kRouteLeads = '/leads';
const String kRouteLeadDetails = '/lead-details';
const String kRouteAddEditLead = '/add-edit-lead';
const String kRouteProfile = '/profile';
