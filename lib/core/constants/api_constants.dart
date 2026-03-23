class ApiConstants {
  // NewsAPI.org — live current news with images
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey = '9921ae77c6ab4187b922a6513ee28560';
  static const String country = 'in';

  // Supabase config
  static const String supabaseUrl = 'https://pvxqysckqrvmmcmxtyyz.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2eHF5c2NrcXJ2bW1jbXh0eXl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzg5NTAsImV4cCI6MjA4OTgxNDk1MH0.IUjsTq8RGVAVwHr5u4SJraP7VwSsXdo1eMuFoWtuZkg';

  static const List<String> categories = [
    'general',
    'business',
    'technology',
    'science',
    'health',
    'sports',
    'entertainment',
  ];

  static const Map<String, String> categoryLabels = {
    'general': 'Breaking News',
    'business': 'Business',
    'technology': 'Trending',
    'science': 'Science',
    'health': 'Health',
    'sports': 'Sports',
    'entertainment': 'Most Debated',
  };
}
