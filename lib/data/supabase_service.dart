import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtbWpicHl3eHF5dXpiaXd1amRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MTg5NDcsImV4cCI6MjA3NjE5NDk0N30.N7dzPheErR4jOX5F4q9lknoedzCeUgdn7AjFKpWlsEY',
      url: 'https://gmmjbpywxqyuzbiwujdp.supabase.co',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> signUp(String email, String password) async {
    try {
      await client.auth.signUp(email: email, password: password);
    } on AuthApiException {
      rethrow;
    }
  }

  static Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthApiException {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}