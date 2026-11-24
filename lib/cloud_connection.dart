import 'package:supabase_flutter/supabase_flutter.dart';

/// Client-side Supabase configuration. The publishable key is intended for
/// client apps; access is protected by database RLS policies.
class CloudConnection {
  static const projectUrl = 'https://bgebhdsahnlvpqogeovm.supabase.co';
  static const publishableKey = 'sb_publishable_W0QLKxSXWbF6GLFW4R2tfA_O3SEkkdd';
  static bool initialized = false;
  static String? initializationError;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(url: projectUrl, anonKey: publishableKey);
      initialized = true;
    } catch (e) {
      initializationError = e.toString();
      initialized = false;
    }
  }

  static Future<String> checkDatabase() async {
    if (!initialized) {
      return 'تعذر تهيئة الاتصال: ${initializationError ?? 'غير معروف'}';
    }
    try {
      await Supabase.instance.client.from('companies').select('id').limit(1);
      return 'الاتصال ناجح وقاعدة بيانات StockPro موجودة.';
    } on PostgrestException catch (e) {
      if (e.code == '42P01' || e.message.toLowerCase().contains('companies')) {
        return 'الاتصال بالمشروع تم، لكن جداول StockPro غير جاهزة. شغّل ملفات Migration من SQL Editor.';
      }
      return 'وصلنا للمشروع، لكن فحص قاعدة البيانات رجع: ${e.message}';
    } catch (e) {
      return 'فشل فحص الاتصال: ${e.toString()}';
    }
  }
}
