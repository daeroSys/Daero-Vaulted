// ignore_for_file: avoid_print, deprecated_member_use
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholder-key',
    );
    print('SUCCESS');
  } catch (e) {
    print('ERROR: $e');
  }
}
