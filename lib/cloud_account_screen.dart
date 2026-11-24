import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cloud_connection.dart';

class CloudAccountScreen extends StatefulWidget {
  const CloudAccountScreen({super.key});
  @override
  State<CloudAccountScreen> createState() => _CloudAccountScreenState();
}
class _CloudAccountScreenState extends State<CloudAccountScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final company = TextEditingController();
  bool busy = false;
  String message = '';
  User? get currentUser => CloudConnection.initialized ? Supabase.instance.client.auth.currentUser : null;

  Future<void> authenticate(bool register) async {
    if (!CloudConnection.initialized) { setState(() => message = 'اتصال الكلاود غير مهيأ.'); return; }
    setState(() { busy = true; message = ''; });
    try {
      final auth = Supabase.instance.client.auth;
      if (register) {
        final result = await auth.signUp(email: email.text.trim(), password: password.text);
        message = result.session == null ? 'تم التسجيل. راجع بريدك لتأكيد الحساب، ثم سجّل الدخول.' : 'تم التسجيل وتسجيل الدخول.';
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
        message = 'تم تسجيل الدخول بنجاح.';
      }
    } on AuthException catch (e) { message = e.message; }
    catch (e) { message = 'تعذر إكمال العملية: $e'; }
    if (mounted) setState(() => busy = false);
  }

  Future<void> createCompany() async {
    if (currentUser == null) { setState(() => message = 'سجّل الدخول أولًا.'); return; }
    if (company.text.trim().length < 2) { setState(() => message = 'اسم الشركة يجب أن يكون حرفين على الأقل.'); return; }
    setState(() { busy = true; message = ''; });
    try {
      final result = await Supabase.instance.client.rpc('create_company_for_current_user', params: {'company_name': company.text.trim()});
      message = 'تم إنشاء الشركة بنجاح. معرف الشركة: $result';
    } on PostgrestException catch (e) { message = 'تعذر الإنشاء. تأكد من تشغيل Migration 0003. ${e.message}'; }
    catch (e) { message = 'حدث خطأ: $e'; }
    if (mounted) setState(() => busy = false);
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) setState(() => message = 'تم تسجيل الخروج.');
  }

  @override
  void dispose() { email.dispose(); password.dispose(); company.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('حساب الكلاود')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('تسجيل حساب أو دخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('هذا الحساب مستقل عن PIN المستخدم محليًا.'),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
          const SizedBox(height: 10),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            FilledButton(onPressed: busy ? null : () => authenticate(false), child: const Text('دخول')),
            OutlinedButton(onPressed: busy ? null : () => authenticate(true), child: const Text('إنشاء حساب')),
          ]),
        ]))),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('إنشاء شركة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(user == null ? 'يجب تسجيل الدخول أولًا.' : 'الحساب: ${user.email ?? user.id}'),
          const SizedBox(height: 10),
          TextField(controller: company, decoration: const InputDecoration(labelText: 'اسم الشركة')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: busy || user == null ? null : createCompany, icon: const Icon(Icons.business), label: const Text('إنشاء الشركة')),
          if (user != null) TextButton.icon(onPressed: busy ? null : logout, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
        ]))),
        if (busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        if (message.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(message))),
        const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('تنبيه: تسجيل الحساب وإنشاء الشركة هما تأسيس الكلاود فقط. مزامنة بيانات البرنامج المحلي لم تُفعّل بعد.'))),
      ]),
    );
  }
}
