import 'package:flutter/foundation.dart';
import 'package:paper_league/data/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase when credentials are present; otherwise no-op (DEMO mode).
Future<bool> initSupabase() async {
  if (!SupabaseConfig.isConfigured) {
    debugPrint('Paper League: SUPABASE_URL/ANON_KEY missing → DEMO league mode');
    return false;
  }
  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use — package still documents anonKey; publishableKey alias
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  return true;
}

SupabaseClient? get supabaseOrNull {
  if (!SupabaseConfig.isConfigured) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
