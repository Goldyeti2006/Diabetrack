class ServerException implements Exception {}

class CacheException implements Exception {
  final String message;

  // Using square brackets [] instead of curly braces {}
  // makes it an optional positional argument, which fixes the error.
  CacheException([this.message = 'A cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}