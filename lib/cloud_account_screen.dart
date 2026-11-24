import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? cloudCompanyId;
  String? cloudCompanyUserId;
  @override void initState() { super.initState(); _loadCompanyLink(); }
  Future<void> _loadCompanyLink() async { final p=await SharedPreferences.getInstance(); cloudCompanyId=p.getString('cloudCompanyId'); cloudCompanyUserId=p.getString('cloudCompanyUserId'); if(mounted)setState((){}); }
  bool get hasCompanyLink => currentUser!=null && cloudCompanyUserId==currentUser!.id && (cloudCompanyId??'').isNotEmpty;
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
      final prefs=await SharedPreferences.getInstance(); await prefs.setString('cloudCompanyId', result.toString()); await prefs.setString('cloudCompanyUserId', currentUser!.id); cloudCompanyId=result.toString(); cloudCompanyUserId=currentUser!.id; message = 'تم إنشاء الشركة وربط الحساب بها. يمكنك الآن رفع نسخة بياناتك للكلاود.';
    } on PostgrestException catch (e) { message = 'تعذر الإنشاء. تأكد من تشغيل Migration 0003. ${e.message}'; }
    catch (e) { message = 'حدث خطأ: $e'; }
    if (mounted) setState(() => busy = false);
  }

  Future<void> syncUpload() async {
    if(!hasCompanyLink){setState(()=>message='أنشئ الشركة من الحساب الحالي أولاً.');return;}
    setState(()=>busy=true);
    try {
      final prefs=await SharedPreferences.getInstance();
      const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','users','activeUser','auditLogs','expenses'];
      final snapshot=<String,dynamic>{'app':'StockPro','schema':1,'savedAt':DateTime.now().toIso8601String()};
      for(final k in keys){snapshot[k]=prefs.get(k);}
      final revision=await Supabase.instance.client.rpc('save_user_snapshot',params:{'target_company':cloudCompanyId,'snapshot':snapshot});
      message='تم رفع نسخة بياناتك للكلاود بنجاح (نسخة رقم $revision).';
    } on PostgrestException catch(e){message='فشل الرفع. تأكد من تشغيل Migration 0004: ${e.message}';}
    catch(e){message='فشل رفع البيانات: $e';}
    if(mounted)setState(()=>busy=false);
  }

  Future<void> syncDownload() async {
    if(!hasCompanyLink){setState(()=>message='أنشئ الشركة من الحساب الحالي أولاً.');return;}
    setState(()=>busy=true);
    try {
      final response=await Supabase.instance.client.rpc('get_user_snapshot',params:{'target_company':cloudCompanyId});
      if(response is! List || response.isEmpty){message='لا توجد نسخة سحابية لهذا الحساب بعد. ارفع بيانات الجهاز أولاً.';}
      else {
        final row=response.first as Map; final payload=row['payload'];
        if(payload is! Map || payload['app']!='StockPro' || payload['schema']!=1) throw Exception('النسخة السحابية غير متوافقة.');
        final yes=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('تحميل بيانات الكلاود'),content:const Text('سيتم استبدال بيانات StockPro الموجودة على هذا الجهاز ببيانات النسخة السحابية. يفضل عمل نسخة احتياطية محلية قبل المتابعة.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('استبدال البيانات'))]));
        if(yes==true){
          final prefs=await SharedPreferences.getInstance();
          const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','users','activeUser','auditLogs','expenses'];
          for(final key in keys){if(payload.containsKey(key)){final v=payload[key];if(v==null){await prefs.remove(key);}else if(v is String){await prefs.setString(key,v);}else{await prefs.setString(key,jsonEncode(v));}}}
          message='تم تنزيل البيانات. أغلق StockPro وافتحه مرة أخرى لتحديث الشاشة.';
        } else {message='تم إلغاء الاستعادة.';}
      }
    } on PostgrestException catch(e){message='فشل التنزيل. تأكد من تشغيل Migration 0004: ${e.message}';}
    catch(e){message='فشل تنزيل البيانات: $e';}
    if(mounted)setState(()=>busy=false);
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
          FilledButton.icon(onPressed: busy || user == null || hasCompanyLink ? null : createCompany, icon: const Icon(Icons.business), label: const Text(hasCompanyLink?'الشركة مرتبطة بالفعل':'إنشاء الشركة')),
          if (user != null) TextButton.icon(onPressed: busy ? null : logout, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
          if (hasCompanyLink) Padding(padding: const EdgeInsets.only(top:12),child:Text('الشركة المرتبطة: $cloudCompanyId',style:const TextStyle(fontSize:12))),
        ]))),
        if (hasCompanyLink) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('مزامنة بيانات الجهاز',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('هذه المرحلة تحفظ نسخة بياناتك الخاصة بحسابك على الكلاود لاسترجاعها على جهاز آخر بنفس الحساب. لا تتم مشاركة البيانات تلقائيًا مع مستخدمين آخرين.'),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[FilledButton.icon(onPressed:busy?null:syncUpload,icon:const Icon(Icons.cloud_upload),label:const Text('رفع بيانات الجهاز')),OutlinedButton.icon(onPressed:busy?null:syncDownload,icon:const Icon(Icons.cloud_download),label:const Text('تنزيل نسخة الكلاود'))])]))),
        if (busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        if (message.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(message))),
        const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('مهم: قبل استخدام المزامنة، يجب تنفيذ ملفات SQL حتى Migration 0004 في Supabase. ارفع نسخة من جهاز واحد أولاً؛ تنزيل نسخة الكلاود يستبدل بيانات الجهاز. هذه مرحلة مزامنة نسخة شخصية وليست مشاركة فريق كاملة.'))),
      ]),
    );
  }
}
