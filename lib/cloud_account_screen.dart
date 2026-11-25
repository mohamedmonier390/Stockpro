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
  String databaseStatus = '';
  String? cloudCompanyId;
  String? cloudCompanyUserId;
  String cloudSnapshotStatus = 'لم يتم فحص النسخة السحابية بعد.';
  String? localAutoSyncAt;
  int sharedRevision = 0;
  List<Map<String,dynamic>> companyMembers = [];
  final memberEmail = TextEditingController();
  String memberRole = 'staff';
  final memberPermissions = <String>{'المخزون','المخازن'};
  static const companyModules = ['المواقع','الوجبات','المخزون','التقارير','المخازن','المستخدمون','المصروفات','المزامنة'];
  String sharedSnapshotStatus = 'لم يتم فحص بيانات الشركة المشتركة بعد.';
  String companyAutoSyncStatus = 'المزامنة التلقائية لم تبدأ بعد.';
  @override void initState() { super.initState(); _loadCompanyLink(); }
  Future<void> _loadCompanyLink() async { final p=await SharedPreferences.getInstance(); cloudCompanyId=p.getString('cloudCompanyId'); cloudCompanyUserId=p.getString('cloudCompanyUserId'); localAutoSyncAt=p.getString('cloudLastAutoSync'); companyAutoSyncStatus=p.getString('cloudSharedSyncStatus')??companyAutoSyncStatus; if(mounted)setState((){}); if(hasCompanyLink) await checkSnapshotStatus(); }
  String _formatCloudDate(String? raw){if(raw==null||raw.isEmpty)return 'غير متوفر';final d=DateTime.tryParse(raw);if(d==null)return raw;final x=d.toLocal();return '${x.year}/${x.month.toString().padLeft(2,'0')}/${x.day.toString().padLeft(2,'0')} ${x.hour.toString().padLeft(2,'0')}:${x.minute.toString().padLeft(2,'0')}';}
  Future<void> checkSnapshotStatus() async {if(!hasCompanyLink)return;try{final result=await Supabase.instance.client.rpc('get_user_snapshot',params:{'target_company':cloudCompanyId});if(result is List && result.isNotEmpty){final row=result.first as Map;cloudSnapshotStatus='آخر نسخة على السيرفر: ${_formatCloudDate(row['updated_at']?.toString())} — رقم النسخة ${row['revision'] ?? '?'}';}else{cloudSnapshotStatus='لا توجد نسخة احتياطية على السيرفر حتى الآن.';}}catch(e){cloudSnapshotStatus='تعذر قراءة حالة النسخة: $e';}if(mounted)setState((){});}
  bool get hasCompanyLink => currentUser!=null && cloudCompanyUserId==currentUser!.id && (cloudCompanyId??'').isNotEmpty;
  User? get currentUser => CloudConnection.initialized ? Supabase.instance.client.auth.currentUser : null;

  Future<void> testConnection() async {
    setState(() { busy = true; databaseStatus = ''; });
    final result = await CloudConnection.checkDatabase();
    if (mounted) setState(() { busy = false; databaseStatus = result; });
  }

  Future<void> authenticate(bool register) async {
    if (!CloudConnection.initialized) { setState(() => message = 'اتصال الكلاود غير مهيأ.'); return; }
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => message = 'اكتب البريد الإلكتروني وكلمة المرور أولًا.');
      return;
    }
    setState(() { busy = true; message = register ? 'جارٍ إنشاء الحساب والاتصال بالسيرفر...' : 'جارٍ تسجيل الدخول...'; });
    try {
      final auth = Supabase.instance.client.auth;
      if (register) {
        final result = await CloudConnection.retryDns(() => auth.signUp(email: email.text.trim(), password: password.text));
        message = result.session == null ? 'تم التسجيل. راجع بريدك لتأكيد الحساب، ثم سجّل الدخول.' : 'تم التسجيل وتسجيل الدخول.';
      } else {
        await CloudConnection.retryDns(() => auth.signInWithPassword(email: email.text.trim(), password: password.text));
        message = 'تم تسجيل الدخول بنجاح.';
      }
    } on AuthException catch (e) {
      message = e.message.contains('already registered') || e.message.contains('already exists')
          ? 'الحساب موجود بالفعل. استخدم زر «دخول» بدل «إنشاء حساب».'
          : 'تعذر تسجيل الحساب: ${e.message}';
    } catch (e) {
      final error = e.toString().toLowerCase();
      message = error.contains('failed host lookup') || error.contains('no address associated')
          ? 'تعذر الوصول للسيرفر بعد 3 محاولات. الاتصال يعمل في المتصفح لكن التطبيق ما زال يواجه DNS؛ جرّب شبكة أخرى ثم أعد المحاولة.'
          : 'تعذر إكمال العملية: ${e.toString()}';
    }
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
      final now=DateTime.now().toIso8601String(); await prefs.setString('cloudLastAutoSync',now); localAutoSyncAt=now; message='تم رفع نسخة بياناتك للكلاود بنجاح (نسخة رقم $revision).'; await checkSnapshotStatus();
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
          // Save a rollback copy locally before overwriting live data.
          final localBackup=<String,dynamic>{'createdAt':DateTime.now().toIso8601String()};
          for(final key in keys){localBackup[key]=prefs.get(key);}
          await prefs.setString('cloudRestoreSafetyBackup',jsonEncode(localBackup));
          // Missing cloud keys are left untouched to avoid partial destructive restores.
          for(final key in keys){if(payload.containsKey(key)){final v=payload[key];if(v==null){await prefs.remove(key);}else if(v is String){await prefs.setString(key,v);}else{await prefs.setString(key,jsonEncode(v));}}}
          message='تم تنزيل البيانات بأمان. تم حفظ نسخة محلية قبل الاستبدال، ويمكنك التراجع من زر استعادة النسخة المحلية. أغلق StockPro وافتحه مرة أخرى لتحديث الشاشة.';
        } else {message='تم إلغاء الاستعادة.';}
      }
    } on PostgrestException catch(e){message='فشل التنزيل. تأكد من تشغيل Migration 0004: ${e.message}';}
    catch(e){message='فشل تنزيل البيانات: $e';}
    if(mounted)setState(()=>busy=false);
  }

  Future<void> loadCompanyMembers() async {
    if(!hasCompanyLink)return;
    try {
      final rows=await Supabase.instance.client.rpc('list_company_members',params:{'target_company':cloudCompanyId});
      companyMembers=(rows as List).map((x)=>Map<String,dynamic>.from(x as Map)).toList();
    } catch(e){message='تعذر تحميل أعضاء الشركة: $e';}
    if(mounted)setState((){});
  }
  Future<void> addCompanyMember() async {
    if(!hasCompanyLink){setState(()=>message='اربط الحساب بالشركة أولًا.');return;}
    if(memberEmail.text.trim().isEmpty){setState(()=>message='اكتب بريد المستخدم.');return;}
    setState(()=>busy=true);
    try {
      await Supabase.instance.client.rpc('add_company_member_by_email',params:{'target_company':cloudCompanyId,'member_email':memberEmail.text.trim(),'member_role':memberRole,'member_permissions':memberPermissions.toList()});
      message='تم إضافة المستخدم للشركة وتحديث صلاحياته. يجب أن يسجل دخول بنفس حساب الكلاود.';
      memberEmail.clear();
      await loadCompanyMembers();
    }on PostgrestException catch(e){message=e.message.contains('ACCOUNT_NOT_FOUND')?'الحساب غير موجود. المستخدم يسجل حساب Cloud في StockPro أولًا، وبعدها أضفه هنا.':e.message;}
    catch(e){message='فشل إضافة المستخدم: $e';}
    if(mounted)setState(()=>busy=false);
  }
  Future<void> removeCompanyMember(String id,String email) async {
    final yes=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('إزالة عضو'),content:Text('هل تريد إزالة $email من الشركة؟'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('إزالة'))]));
    if(yes!=true)return;
    setState(()=>busy=true);
    try{await Supabase.instance.client.rpc('remove_company_member',params:{'target_company':cloudCompanyId,'member_user':id});message='تم إزالة العضو.';await loadCompanyMembers();}
    catch(e){message='تعذر إزالة العضو: $e';}
    if(mounted)setState(()=>busy=false);
  }

  Future<void> checkSharedSnapshotStatus() async {
    if(!hasCompanyLink)return;
    try {
      final result=await Supabase.instance.client.rpc('get_company_snapshot',params:{'target_company':cloudCompanyId});
      if(result is List && result.isNotEmpty){final row=result.first as Map;sharedRevision=int.tryParse(row['revision'].toString())??0;sharedSnapshotStatus='بيانات الشركة المشتركة — آخر تحديث: ${_formatCloudDate(row['updated_at']?.toString())} | Revision: $sharedRevision';}
      else {sharedRevision=0;sharedSnapshotStatus='لا توجد بيانات مشتركة على السيرفر بعد (Revision 0).';}
    } catch(e) {sharedSnapshotStatus='تعذر قراءة بيانات الشركة المشتركة: $e';}
    if(mounted)setState((){});
  }

  Future<void> uploadSharedCompanyData() async {
    if(!hasCompanyLink){setState(()=>message='اربط الحساب بالشركة أولًا.');return;}
    setState(()=>busy=true);
    try {
      await checkSharedSnapshotStatus();
      final prefs=await SharedPreferences.getInstance();
      const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','auditLogs','expenses'];
      final snapshot=<String,dynamic>{'app':'StockPro','schema':1,'savedAt':DateTime.now().toIso8601String()};
      for(final k in keys){snapshot[k]=prefs.get(k);}
      final rev=await Supabase.instance.client.rpc('save_company_snapshot',params:{'target_company':cloudCompanyId,'snapshot':snapshot,'expected_revision':sharedRevision});
      sharedRevision=int.tryParse(rev.toString())??sharedRevision+1;
      await prefs.setInt('cloudSharedRevisionBaseline',sharedRevision);await prefs.setString('cloudSharedSyncStatus','تمت المزامنة اليدوية — Revision $sharedRevision');companyAutoSyncStatus='تمت المزامنة اليدوية — Revision $sharedRevision';
      message='تم رفع بيانات الشركة المشتركة بنجاح — Revision $sharedRevision. أي جهاز قديم لازم ينزّل آخر نسخة قبل رفع تعديلاته.';
      await checkSharedSnapshotStatus();
    } on PostgrestException catch(e) {
      final msg=e.message;
      message=msg.contains('REVISION_CONFLICT')?'⚠️ حصل تعديل من جهاز آخر. حدّث الحالة ثم نزّل أحدث نسخة قبل الرفع.':msg.contains('Sync permission')?'الحساب لا يملك صلاحية مزامنة بيانات الشركة. اطلب من المدير تفعيل صلاحية «المزامنة».':'فشل رفع بيانات الشركة: $msg';
    } catch(e){message='فشل رفع بيانات الشركة المشتركة: $e';}
    if(mounted)setState(()=>busy=false);
  }

  Future<void> downloadSharedCompanyData() async {
    if(!hasCompanyLink){setState(()=>message='اربط الحساب بالشركة أولًا.');return;}
    setState(()=>busy=true);
    try {
      final response=await Supabase.instance.client.rpc('get_company_snapshot',params:{'target_company':cloudCompanyId});
      if(response is! List || response.isEmpty){message='لا توجد بيانات مشتركة بعد. أول جهاز يرفع بيانات الشركة.';}
      else {
        final row=response.first as Map;final payload=row['payload'];
        if(payload is! Map || payload['app']!='StockPro' || payload['schema']!=1)throw Exception('البيانات المشتركة غير متوافقة.');
        final remoteRev=int.tryParse(row['revision'].toString())??0;
        final yes=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('تنزيل بيانات الشركة المشتركة'),content:Text('سيتم استبدال بيانات التشغيل المحلية ببيانات الشركة المشتركة Revision $remoteRev. سيتم حفظ نسخة محلية للتراجع. بيانات حسابات PIN المحلية لن يتم استبدالها.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('تنزيل واستبدال'))]));
        if(yes==true){
          final prefs=await SharedPreferences.getInstance();
          const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','auditLogs','expenses'];
          final backup=<String,dynamic>{'createdAt':DateTime.now().toIso8601String()};
          for(final key in keys){backup[key]=prefs.get(key);}
          await prefs.setString('cloudRestoreSafetyBackup',jsonEncode(backup));
          for(final key in keys){if(payload.containsKey(key)){final v=payload[key];if(v==null){await prefs.remove(key);}else if(v is String){await prefs.setString(key,v);}else{await prefs.setString(key,jsonEncode(v));}}}
          sharedRevision=remoteRev;await prefs.setInt('cloudSharedRevisionBaseline',remoteRev);await prefs.setString('cloudSharedSyncStatus','تم تنزيل أحدث نسخة — Revision $remoteRev');companyAutoSyncStatus='تم تنزيل أحدث نسخة — Revision $remoteRev';
          message='تم تنزيل بيانات الشركة المشتركة Revision $remoteRev. نسخة محلية محفوظة للتراجع. أغلق البرنامج وافتحه لتحديث الشاشة.';
        }else{message='تم إلغاء التنزيل.';}
      }
      await checkSharedSnapshotStatus();
    } on PostgrestException catch(e){message='فشل التنزيل المشترك: ${e.message}';}
    catch(e){message='فشل تنزيل بيانات الشركة: $e';}
    if(mounted)setState(()=>busy=false);
  }

  Future<void> rollbackCloudRestore() async {
    final prefs=await SharedPreferences.getInstance();
    final raw=prefs.getString('cloudRestoreSafetyBackup');
    if(raw==null){setState(()=>message='لا توجد نسخة محلية محفوظة للتراجع.');return;}
    final backup=jsonDecode(raw);
    if(backup is! Map) {setState(()=>message='النسخة المحلية غير صالحة.');return;}
    final backupDate=_formatCloudDate(backup['createdAt']?.toString());
    final yes=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('استعادة بيانات الجهاز السابقة'),content:Text('سيتم إرجاع البيانات المحلية التي تم حفظها قبل آخر تنزيل من الكلاود ('+backupDate+').'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('استعادة النسخة المحلية'))]));
    if(yes!=true)return;
    const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','users','activeUser','auditLogs','expenses'];
    for(final key in keys){if(backup.containsKey(key)){final v=backup[key];if(v==null){await prefs.remove(key);}else if(v is String){await prefs.setString(key,v);}else{await prefs.setString(key,jsonEncode(v));}}}
    if(mounted)setState(()=>message='تمت استعادة نسخة الجهاز السابقة. أغلق StockPro وافتحه مرة أخرى.');
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) setState(() => message = 'تم تسجيل الخروج.');
  }

  @override
  void dispose() { email.dispose(); password.dispose(); company.dispose(); memberEmail.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('حساب الكلاود')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('حالة الاتصال بالسيرفر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('تم تجهيز قاعدة البيانات على Supabase. اضغط لفحص اتصال التطبيق الفعلي.'),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: busy ? null : testConnection, icon: const Icon(Icons.cloud_done), label: const Text('فحص الاتصال')),
          if (databaseStatus.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(databaseStatus)),
        ]))),
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
          FilledButton.icon(onPressed: busy || user == null || hasCompanyLink ? null : createCompany, icon: const Icon(Icons.business), label: Text(hasCompanyLink?'الشركة مرتبطة بالفعل':'إنشاء الشركة')),
          if (user != null) TextButton.icon(onPressed: busy ? null : logout, icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
          if (hasCompanyLink) Padding(padding: const EdgeInsets.only(top:12),child:Text('الشركة المرتبطة: $cloudCompanyId',style:const TextStyle(fontSize:12))),
        ]))),
        if (hasCompanyLink) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('النسخ الاحتياطي الشخصي',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('نسخة خاصة بحسابك لاستعادة بياناتك على جهاز آخر.'),const SizedBox(height:10),Text('آخر رفع تلقائي: ${_formatCloudDate(localAutoSyncAt)}'),const SizedBox(height:6),Text(cloudSnapshotStatus),const SizedBox(height:10),OutlinedButton.icon(onPressed:busy?null:checkSnapshotStatus,icon:const Icon(Icons.refresh),label:const Text('تحديث حالة النسخة')),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[FilledButton.icon(onPressed:busy?null:syncUpload,icon:const Icon(Icons.cloud_upload),label:const Text('رفع النسخة الشخصية')),OutlinedButton.icon(onPressed:busy?null:syncDownload,icon:const Icon(Icons.cloud_download),label:const Text('تنزيل النسخة الشخصية')),OutlinedButton.icon(onPressed:busy?null:rollbackCloudRestore,icon:const Icon(Icons.undo),label:const Text('استعادة النسخة المحلية السابقة'))])]))),
        if (hasCompanyLink) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('أعضاء الشركة وصلاحياتهم',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
          const SizedBox(height:8),
          const Text('إضافة الأعضاء تتم بالبريد الإلكتروني بعد أن يسجل المستخدم حساب Cloud في StockPro.'),
          const SizedBox(height:10),
          TextField(controller:memberEmail,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'بريد المستخدم المسجل')),
          const SizedBox(height:8),
          DropdownButtonFormField<String>(value:memberRole,decoration:const InputDecoration(labelText:'دور المستخدم'),items:const [DropdownMenuItem(value:'staff',child:Text('موظف')),DropdownMenuItem(value:'manager',child:Text('مشرف'))],onChanged:(v)=>setState(()=>memberRole=v??'staff')),
          const SizedBox(height:8),
          const Text('الصلاحيات المسموحة'),
          ...companyModules.map((p)=>CheckboxListTile(dense:true,contentPadding:EdgeInsets.zero,title:Text(p),subtitle:p=='المزامنة'?const Text('تتيح الوصول إلى بيانات التشغيل المشتركة كاملة بين أجهزة الشركة. امنحها فقط للمستخدمين الموثوقين.'):null,value:memberPermissions.contains(p),onChanged:(v)=>setState(()=>v==true?memberPermissions.add(p):memberPermissions.remove(p)))),
          FilledButton.icon(onPressed:busy?null:addCompanyMember,icon:const Icon(Icons.person_add_alt_1),label:const Text('إضافة / تحديث العضو')),
          const Divider(),
          OutlinedButton.icon(onPressed:busy?null:loadCompanyMembers,icon:const Icon(Icons.refresh),label:const Text('عرض أعضاء الشركة')),
          ...companyMembers.map((m)=>ListTile(title:Text(m['email']?.toString()??'بدون بريد'),subtitle:Text('الدور: ${m['role']} | صلاحيات: ${(m['permissions'] as List? ?? []).join('، ')}'),trailing:IconButton(icon:const Icon(Icons.person_remove_alt_1,color:Colors.red),onPressed:busy?null:()=>removeCompanyMember(m['user_id'].toString(),m['email']?.toString()??'عضو')))),
        ]))),
        if (hasCompanyLink) Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('مشاركة بيانات الشركة بين الأجهزة',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('هذه مساحة مشتركة للشركة، وليست النسخة الشخصية. ارفع من جهاز واحد أولًا. قبل رفع جهاز آخر، نزّل أحدث نسخة لتجنب تعارض التعديلات. حماية Revision تمنع رفع نسخة قديمة فوق تحديث أحدث. حسابات PIN المحلية تبقى منفصلة.'),const SizedBox(height:8),Text(sharedSnapshotStatus),const SizedBox(height:6),Text(companyAutoSyncStatus,style:const TextStyle(fontSize:13)),const SizedBox(height:10),OutlinedButton.icon(onPressed:busy?null:checkSharedSnapshotStatus,icon:const Icon(Icons.sync),label:const Text('تحديث حالة المشاركة')),const SizedBox(height:10),Wrap(spacing:8,runSpacing:8,children:[FilledButton.icon(onPressed:busy?null:uploadSharedCompanyData,icon:const Icon(Icons.cloud_upload_outlined),label:const Text('رفع بيانات الشركة')),OutlinedButton.icon(onPressed:busy?null:downloadSharedCompanyData,icon:const Icon(Icons.cloud_download_outlined),label:const Text('تنزيل بيانات الشركة')),OutlinedButton.icon(onPressed:busy?null:rollbackCloudRestore,icon:const Icon(Icons.undo),label:const Text('التراجع عن الاستبدال'))])]))),
        if (busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
        if (message.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(message))),
        const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('النسخة الاحتياطية الشخصية تُرفع بعد الحفظ عند توفر الاتصال. بيانات الشركة المشتركة تخضع لصلاحية «المزامنة» ورقم Revision لمنع الكتابة فوق تحديث أحدث؛ عند وصول تعديل من جهاز آخر، نزّل أحدث نسخة على هذا الجهاز قبل متابعة العمل.'))),
      ]),
    );
  }
}
