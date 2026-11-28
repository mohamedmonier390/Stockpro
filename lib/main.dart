import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart' as zip;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cloud_connection.dart';
import 'cloud_account_screen.dart';
ValueNotifier<String> appLanguage = ValueNotifier<String>('ar');
String languageText(String arabic, String english) => appLanguage.value == 'en' ? english : arabic;
String translateEnglish(String input){ if(appLanguage.value!='en') return input; final translations=<String,String>{"لم أجد ورقة بيانات بعناوين صحيحة. استخدم قالب StockPro وتأكد من وجود أعمدة كود الصنف واسم الصنف ووحدة القياس والمخزن.":"No valid header row found. Use the StockPro template and ensure columns for item code, item name, unit and warehouse.","زر فحص الاتصال يتحقق من الوصول إلى قاعدة StockPro فقط، ولا ينقل أو يرفع بيانات الجهاز.":"The connection check only verifies access to StockPro database; it does not upload or transfer device data.","استخدم أسماء المخازن المطابقة تماماً للمخازن المسجلة. يمكنك استخدام المخزن الرئيسي.":"Use warehouse names exactly as registered. You may use the main warehouse.","لا يمكن حذف خامة مرتبطة بحركات مخزون أو وصفات. يمكنك تعديل بياناتها بدلاً من ذلك.":"Cannot delete an item linked to inventory movements or recipes. You can edit it instead.","لا يمكن حذف سجل قديم غير مرتبط بحركات الاستهلاك؛ حفاظاً على دقة أرصدة المخازن.":"Cannot delete an older record not linked to consumption movements, to protect inventory accuracy.","كل صنف يجب أن يكون له كود فريد واسم ووحدة قياس ومخزن موجود داخل البرنامج.":"Each item must have a unique code, name, unit and an existing warehouse.","احذف صف المثال، ثم احفظ الملف بصيغة Excel .xlsx واستورده من شاشة المخزون.":"Delete the sample row, save as Excel .xlsx, then import it from Inventory.","إدارة مواقع التغذية والمخازن والوجبات والمصروفات في مكان واحد.":"Manage catering sites, warehouses, meals and expenses in one place.","لا توجد وجبات مسجلة خلال الفترة المختارة للمواقع المسموح بها.":"No meal records in the selected period for permitted sites.","لم أستطع قراءة الملف. احفظه بصيغة Excel .xlsx وحاول مرة أخرى.":"Could not read the file. Save it as Excel .xlsx and try again.","تمت الاستعادة. سيتم إعادة فتح البرنامج بالبيانات المستعادة.":"Backup restored. The app will reopen with restored data.","الاستلام والصرف والتحويلات تُسجل على المخزن المحدد.":"Receipts, issues and transfers are recorded against the selected warehouse.","• إدارة المواقع والعقود وتسجيل الوجبات اليومية.":"• Manage sites, contracts and daily meal records.","الوجبات • المخزون • الإيرادات • متابعة المواقع":"Meals • Inventory • Revenue • Site tracking","لازم يكون عندك مخزنان على الأقل لإجراء التحويل":"At least two warehouses are required for a transfer","عند تسجيل الوجبات سيتم خصم الاستهلاك تلقائيًا.":"Consumption will be deducted automatically when meals are recorded.","راجع البيانات وأدخل أرقامًا صحيحة غير سالبة":"Check the fields and enter valid non-negative numbers","التنبيه عند تجاوز الاستهلاك المتوقع بنسبة ":"Alert when consumption exceeds expected by ","• وصفات واستهلاك خامات وتقارير ومصروفات.":"• Recipes, material consumption, reports and expenses.","من الأعلى تكلفة إلى الأقل — الشهر الحالي":"Highest to lowest cost — current month","لا توجد خامات أو لا توجد مخازن مسموح بها":"No items or no permitted warehouses","أدخل اسم الموقع وأسعارًا صحيحة غير سالبة":"Enter a site name and valid non-negative prices","الكمية غير صحيحة أو رصيد المصدر غير كافٍ":"Invalid quantity or insufficient source balance","StockPro Business - قالب استيراد المخزون":"StockPro Business - Inventory import template","• استيراد Excel ونسخ احتياطي واستعادة.":"• Excel import, backup and restore.","• مخازن مستقلة وتحويلات وجرد وتسويات.":"• Separate warehouses, transfers, stock counts and adjustments.","StockPro Business • إصدار تجهيز تجاري":"StockPro Business • Commercial edition","ترتيب الهالك والانحراف — الشهر الحالي":"Waste & variance ranking — current month","تكلفة الخامات المصروفة فعليًا للمواقع":"Actual materials cost issued to sites","بحث بالمستخدم أو العملية أو التفاصيل":"Search user, action or details","مراقبة الاستهلاك والانحراف عن الوصفة":"Monitor consumption and recipe variance","اختيار الحد الذي يبدأ عنده التنبيه":"Set the threshold that triggers alerts","لا توجد وصفات أو صرف يدوي للمقارنة":"No recipes or manual issues to compare","لا يوجد مخزن موقع مسموح بالصرف منه":"No permitted site warehouse for issuing","لا يوجد مخزن مسموح لك بالتعامل معه":"No warehouse is permitted for your account","الرصيد الفعلي مطابق للرصيد الدفتري":"Actual balance matches book balance","لا توجد تنبيهات خلال الشهر الحالي":"No alerts this month","تم حفظ قالب استيراد المخزون بنجاح":"Inventory template saved successfully","تم إنشاء النسخة الاحتياطية بنجاح":"Backup created successfully","مراجعات تنبيهات الهالك غير سليمة":"Waste alert reviews are invalid","• مستخدمون وصلاحيات وسجل تدقيق.":"• Users, permissions and audit log.","سبب الانحراف / الإجراء التصحيحي":"Variance reason / corrective action","إدارة مواقع التغذية\\nبكل سهولة":"Easy catering site management","تنبيه لم يُراجع • الشهر الحالي":"unreviewed alert • this month","ممتاز! لا توجد تنبيهات حسب حد ":"Excellent! No alerts at threshold "," تنبيه إضافي في تقرير الانحراف":" additional alerts in variance report","إجمالي تكلفة الصنف خلال الفترة":"Total item cost for period","مثال - احذف الصف قبل الاستيراد":"Example - delete this row before import","تعذر تجهيز ملف Excel للاستيراد":"Could not prepare Excel file for import","؟ سيتم حذف أرصدتها من المخازن.":"? Its warehouse balances will be deleted.","الملف فارغ أو غير قابل للقراءة":"File is empty or unreadable","الملف ليس نسخة StockPro معتمدة":"This is not a valid StockPro backup","اسم المستخدم والـ PIN مطلوبان":"Username and PIN are required","تكلفة الخامات المصروفة فعليًا":"Actual materials cost issued","تحديد استهلاك الخامة لكل وجبة":"Set material consumption per meal","الكمية لكل وجبة بوحدة المخزون":"Quantity per meal in inventory unit","فشل إنشاء النسخة الاحتياطية: ":"Backup creation failed: ","تغيير نسبة التنبيه الحالية: ":"Current alert threshold: ","تكلفة الموقع من الصرف الفعلي":"Site cost from actual issues","متوسط تكلفة الخامات لكل وجبة":"Average material cost per meal","أدخل أعداداً صحيحة غير سالبة":"Enter valid non-negative whole numbers","لا توجد خامات أو مخازن متاحة":"No materials or warehouses available","مصروفات المواقع خلال الفترة":"Site expenses during period"," • أسعار الوجبات تم تحديثها":" • Meal prices updated","تنبيهات الهالك والانحراف (":"Waste & variance alerts (","أعلى موقع في تكلفة الخامات":"Site with highest material cost","الاستعادة متاحة للمدير فقط":"Restore is available to administrators only","اسم المستخدم موجود بالفعل":"Username already exists","عرض ترتيب جميع الانحرافات":"View all variances ranked","أدخل رصيدًا فعليًا صحيحًا":"Enter a valid actual balance","فتح تقرير تحليل الانحراف":"Open variance analysis report","الفائض بعد تكلفة الخامات":"Surplus after materials cost","صافي الربح بعد المصروفات":"Net profit after expenses","تقرير الوجبات والإيرادات":"Meals & revenue report","تكلفة الانحراف الصافية: ":"Net variance cost: ","تفصيل التكلفة حسب الخامة":"Cost breakdown by item","حالة البيانات والخصوصية":"Data & privacy status","متابعة الهالك والانحراف":"Waste & variance monitoring","تصدير التقرير إلى Excel":"Export report to Excel","تفصيل الأداء حسب الموقع":"Performance by site","اسم الموقع موجود بالفعل":"Site name already exists","اسم الخامة موجود بالفعل":"Material name already exists","أرصدة المخازن غير سليمة":"Warehouse balances are invalid","الرصيد الفعلي بعد الجرد":"Actual counted balance","إجمالي مصروفات المواقع":"Total site expenses","تكرر خلال آخر 3 شهور: ":"Repeated in last 3 months: ","استيراد بيانات المخزون":"Import inventory","إيراد الوجبات المسعّرة":"Revenue from priced meals","تحليل الانحراف والهالك":"Variance & waste analysis","تم تصدير التقرير بنجاح":"Report exported successfully","يوجد مخزن رئيسي بالفعل":"A main warehouse already exists","وجبات إضافية غير مسعرة":"Unpriced extra meals","المستخدمون والصلاحيات":"Users & permissions","خامات وصلت حد التنبيه":"Items at reorder threshold","صرف للاستهلاك بالموقع":"Issue to site consumption","تسجيل الوجبات اليومية":"Record daily meals","رصيد غير كافٍ بالمخزن":"Insufficient warehouse stock","تعذر إنشاء قالب Excel":"Could not create Excel template","استعادة نسخة احتياطية":"Restore backup","تعذر استعادة النسخة: ":"Restore failed: ","مدير — صلاحيات كاملة":"Administrator — Full access","تحميل قالب الاستيراد":"Download import template","تعذر إنشاء ملف Excel":"Could not create Excel file","تم إلغاء حفظ التقرير":"Report save cancelled","الموقع / نطاق المخزن":"Site / warehouse scope","تعديل الموقع / العقد":"Edit site / contract","اختار مخزنين مختلفين":"Select two different warehouses","بيانات غير سليمة في ":"Invalid data in ","المواقع المسموح بها":"Allowed sites","المخازن المسموح بها":"Allowed warehouses","التكلفة التقديرية: ":"Estimated cost: ","رصيد مستقل لكل مخزن":"Separate balance for each warehouse","تعديل الموقع والعقد":"Edit site and contract","لا توجد حركات مسجلة":"No movements recorded","صرف الخامات للمواقع":"Material issues to sites","الصرف الفعلي اليدوي":"Manual actual issue","فشل تصدير التقرير: ":"Report export failed: ","سجل موقع وعقد أولاً":"Add a site and contract first","تعديل تسجيل الوجبات":"Edit meal record","ملاحظات / رقم الإذن":"Notes / voucher number","تم إلغاء حفظ القالب":"Template save cancelled","الكود مستخدم بالفعل":"Code already in use","تم إلغاء حفظ النسخة":"Backup save cancelled","StockPro | التغذية":"StockPro | Catering","مراجعة الانحراف • ":"Review variance • ","تمت مراجعة التنبيه":"Alert reviewed","لا توجد بيانات بعد":"No data yet","اختر بداية التقرير":"Select report start date","اختر نهاية التقرير":"Select report end date","فشل إنشاء القالب: ":"Failed to create template: ","مخازن غير مطابقة: ":"Unmatched warehouses: ","سجل المواقع أولاً":"Add a site first","حد تنبيه الانحراف":"Variance alert threshold","اكتب الملاحظة هنا":"Enter your note here","آخر حركات المخزون":"Recent inventory movements","الفترة المختارة: ":"Selected period: ","رصيد غير كافٍ في ":"Insufficient stock in ","سجل حركات المخزون":"Inventory movement log","جرد وتسوية مخزنية":"Stock count & adjustment","رقم PIN (إجباري)":"PIN (required)","المميزات الحالية":"Current features","المخزون والخامات":"Inventory & materials","الاستهلاك النظري":"Theoretical consumption","حدد فترة التقرير":"Select report period","إضافة موقع / عقد":"Add site / contract","الرصيد الافتتاحي":"Opening balance","الرصيد الدفتري: ":"Book balance: ","مصروفات المواقع":"Site expenses","المستخدم الحالي":"Current user","لا توجد تنبيهات":"No alerts","بدون وصفة مسجلة":"without a recorded recipe","المواقع والعقود":"Sites & contracts","تفصيل التسجيلات":"Record details","الزيادة / العجز":"Excess / shortage","نسبة الانحراف %":"Variance %","اكتب اسم المخزن":"Enter warehouse name","حذف سجل الوجبات":"Delete meal record","الرصيد الحالي: ":"Current balance: ","أدخل كمية صحيحة":"Enter a valid quantity","إذن تحويل مخزني":"Warehouse transfer voucher","أضف خامات أولاً":"Add materials first","فشل الاستيراد: ":"Import failed: ","تاريخ غير معروف":"Unknown date","المخزن الرئيسي":"Main warehouse","مصروفات الموقع":"Site expenses","المبلغ بالجنيه":"Amount (EGP)","أدخل مبلغ صحيح":"Enter a valid amount","تعديل المستخدم":"Edit user","تقرير StockPro":"StockPro report","إجمالي الوجبات":"Total meals","إجمالي التكلفة":"Total cost","تكلفة الانحراف":"Variance cost","ملاحظة محاسبية":"Accounting note","أضف خامة أولاً":"Add an item first","الكمية للتحويل":"Transfer quantity","اعتماد التحويل":"Approve transfer","بيانات المخزون":"Inventory data","لا توجد سجلات":"No records","إعداد الكلاود":"Cloud setup","إجراءات سريعة":"Quick actions","نسخة احتياطية":"Backup","إدارة المخازن":"Warehouse management","قيمة الرصيد: ":"Balance value: ","وصفات الوجبات":"Meal recipes","تفصيل المواقع":"Site details","تكلفة الخامات":"Material cost","وجبة • إيراد ":"meals • Revenue ","أسعار العقد: ":"Contract prices: ","حفظ التعديلات":"Save changes","الكمية بوحدة ":"Quantity in ","رصيد المصدر: ":"Source balance: ","رصيد الوجهة: ":"Destination balance: ","رقم التحويل: ":"Transfer number: ","لا توجد حركات":"No movements","متوسط التكلفة":"Average cost","أكواد مكررة: ":"Duplicate codes: ","PIN غير صحيح":"Incorrect PIN","حول StockPro":"About StockPro","تسجيل الخروج":"Log out","إضافة مستخدم":"Add user","اسم المستخدم":"Username","حساب الكلاود":"Cloud account","مراجعة تنبيه":"Review alert","تحديث ملاحظة":"Update note","انحراف مخزون":"Inventory variance","حفظ المراجعة":"Save review","صرف بلا وصفة":"Issue without recipe","قيمة المخزون":"Inventory value","استعادة نسخة":"Restore backup","استلام خامات":"Receive materials","تعديل الخامة":"Edit item","ملخص التقرير":"Report summary","وجبات إضافية":"Extra meals","تكلفة الوحدة":"Unit cost","لا توجد وصفة":"No recipe","الشهر الحالي":"Current month","تعديل المخزن":"Edit warehouse","اعتماد الجرد":"Confirm stock count","تغيير اللغة":"Change language","إضافة مصروف":"Add expense","تعديل مصروف":"Edit expense","نوع المصروف":"Expense category","حذف المصروف":"Delete expense","سجل التدقيق":"Audit log","أمان الدخول":"Login security","فحص الكلاود":"Cloud check","فحص الاتصال":"Check connection","لوحة التحكم":"Dashboard","إيراد اليوم":"Today’s revenue","وجبات اليوم":"Meals today","عدد المواقع":"Sites","عدد الخامات":"Items","تسجيل وجبات":"Record meals","تحويل مخزني":"Warehouse transfer","سجل الحركات":"Movement log","سجل الوجبات":"Meal records","حد التنبيه ":"Alert threshold ","سعر الإفطار":"Breakfast price","عدد الإفطار":"Breakfast count","\$type خامات":"\$type materials","وحدة القياس":"Unit of measure","تم استيراد ":"Imported ","تسوية زيادة":"Positive adjustment","المستخدمون":"Users","حذف مصروف ":"Delete expense ","مصروف جديد":"New expense","السماح بـ ":"Allow ","ملخص اليوم":"Today’s summary","إضافة موقع":"Add site","إضافة خامة":"Add item","جرد وتسوية":"Stock count & adjustment","مخزن رئيسي":"Main warehouse","حذف الخامة":"Delete item","صافي الربح":"Net profit","نوع الحركة":"Movement type","آخر 30 يوم":"Last 30 days","غير مسعّرة":"Unpriced","إضافة مخزن":"Add warehouse","اسم المخزن":"Warehouse name","اسم الموقع":"Site name","سعر الغداء":"Lunch price","سعر العشاء":"Dinner price","موقع / عقد":"Site / contract","عدد الغداء":"Lunch count","عدد العشاء":"Dinner count","حركة مخزون":"Inventory movement","إلى المخزن":"To warehouse","تحويل صادر":"Transfer out","تحويل وارد":"Transfer in","حفظ الوصفة":"Save recipe","حد التنبيه":"Alert threshold","اسم المادة":"Material name","كود/باركود":"Code / barcode","المصروفات":"Expenses","كل الشركة":"Entire company","التاريخ: ":"Date: ","صلاحيات: ":"Permissions: ","نظرة عامة":"Overview"," • متكرر ":" • Repeated ","مخزن جديد":"New warehouse","مخزن فرعي":"Site warehouse"," | إفطار ":" | Breakfast ","صرف خامات":"Issue materials"," • إفطار ":" • Breakfast ","من المخزن":"From warehouse","كود الصنف":"Item code","اسم الصنف":"Item name","مثال: أرز":"Example: Rice","تسوية عجز":"Negative adjustment","الرئيسية":"Home","التقارير":"Reports"," أو أكثر":" or more"," الحالي.":" currently."," / غداء ":" / Lunch "," / عشاء ":" / Dinner ","الإجمالي":"Total","إضافية: ":"Extra: ","تم تخطي ":"Skipped ","حذف خامة":"Delete material"," / فعلي ":" / Actual ","المواقع":"Sites","الوجبات":"Meals","المخزون":"Inventory","المخازن":"Warehouses","العربية":"Arabic","ملاحظات":"Notes"," إضافي ":" Extra ","التاريخ":"Date","التصنيف":"Category","الإيراد":"Revenue","مصروفات":"Expenses","إفطار: ":"Breakfast: ","المسؤول":"Manager"," (متاح ":" (Available ","تعليمات":"Instructions","المدير":"Administrator","الموقع":"Site","مستخدم":"User","زيادة ":"Excess ","إفطار ":"Breakfast "," غداء ":" Lunch "," عشاء ":" Dinner ","استلام":"Receive","المؤشر":"Metric","القيمة":"Value","المبلغ":"Amount","إضافية":"Extra","الفائض":"Surplus","الكمية":"Quantity","الوحدة":"Unit","غداء: ":"Lunch: ","عشاء: ":"Dinner: ","العميل":"Client","الخامة":"Material","الكود ":"Code ","تكلفة ":"Cost ","دفترى ":"Book ","إغلاق":"Close","عمالة":"Labor","إقامة":"Accommodation","صيانة":"Maintenance","إلغاء":"Cancel","إضافة":"Add","مصروف":"Expense","تعديل":"Edit"," مرات":" times","يوجد ":"There are ","الصنف":"Item","تأكيد":"Confirm","تحويل":"Transfer","مخزون":"Inventory","أخرى":"Other","تمام":"OK","موقع":"Site","إلى ":"To ","وارد":"Inbound","صادر":"Outbound","حذف ":"Delete "," ج.م":" EGP","نقل":"Transport","حفظ":"Save","حذف":"Delete","إلى":"To","من ":"From ","كجم":"kg","، ":" , ","من":"From"}; var out=input; for(final entry in translations.entries){out=out.replaceAll(entry.key,entry.value);} return out; }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  appLanguage.value = prefs.getString('appLanguage') == 'en' ? 'en' : 'ar';
  await CloudConnection.initialize(); // Cloud errors never prevent offline use.
  runApp(const App());
}
class MonierBrand extends StatelessWidget{final double size;final bool light;const MonierBrand({super.key,this.size=70,this.light=false});@override Widget build(BuildContext c)=>Column(mainAxisSize:MainAxisSize.min,children:[SizedBox(width:size,height:size,child:Stack(alignment:Alignment.center,children:[Text('M',style:TextStyle(fontSize:size*.82,fontWeight:FontWeight.w900,color:light?Colors.white:const Color(0xff092d50))),Positioned(right:size*.12,bottom:size*.12,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[for(int i=1;i<=3;i++)Container(width:size*.09,height:size*.12*i,margin:EdgeInsets.only(left:size*.025),decoration:BoxDecoration(color:const Color(0xff21a447),borderRadius:BorderRadius.circular(size*.02)))]))])),Text('MONIER',style:TextStyle(fontSize:size*.23,fontWeight:FontWeight.w900,letterSpacing:size*.055,color:light?Colors.white:const Color(0xff092d50))),]);}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xff087c68));
    return MaterialApp(
      title: 'StockPro Business',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xfff4f7f8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xff153b3a),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xffe5eceb)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xfff7faf9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xffdce6e4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: scheme.primaryContainer,
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
      builder: (context, child) => ValueListenableBuilder<String>(
        valueListenable: appLanguage,
        builder: (context, language, _) => Directionality(
          textDirection: language == 'en' ? TextDirection.ltr : TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: const AnimatedSplash(),
    );
  }
}
class LoginScreen extends StatefulWidget{const LoginScreen({super.key});@override State<LoginScreen> createState()=>LoginState();}
class LoginState extends State<LoginScreen>{
  final pin=TextEditingController();List<AppUser> users=[];AppUser? selected;bool loading=true;bool showPin=false;
  @override void initState(){super.initState();loadUsers();}
  Future<void> loadUsers()async{final p=await SharedPreferences.getInstance();try{users=(jsonDecode(p.getString('users')??'[]') as List).map((x)=>AppUser(x['n'],x['pin']??'',x['admin']??false,Set<String>.from(x['p']??AppUser.modules),Set<String>.from(x['sites']??[]),Set<String>.from(x['warehouses']??[]))).toList();}catch(_){}if(users.isEmpty){users=[AppUser('المدير','',true,Set<String>.from(AppUser.modules))];await p.setString('users',jsonEncode(users.map((u)=>u.j()).toList()));}selected=users.first;setState(()=>loading=false);}
  Future<void> enter()async{if(selected==null)return;if(pin.text!=selected!.pin){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('PIN غير صحيح'))));return;}final p=await SharedPreferences.getInstance();await p.setString('activeUser',selected!.name);if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>Hub()));}
  @override
  Widget build(BuildContext c) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final width = MediaQuery.sizeOf(c).width;

    final loginCard = Card(
      elevation: 8,
      shadowColor: const Color(0x33092d50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.groups_rounded, size: 45, color: Color(0xff092d50)),
            SizedBox(width: 10),
            Text('Login', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xff092d50))),
          ]),
          const SizedBox(height: 2),
          const Text('Welcome to StockPro', style: TextStyle(fontSize: 17, color: Color(0xff4b5870), fontStyle: FontStyle.italic)),
          const SizedBox(height: 18),
          DropdownButtonFormField<AppUser>(
            value: selected,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: Color(0xff092d50)),
              hintText: translateEnglish('Username'), filled: true, fillColor: Color(0xfff7f9fc),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xffc5cedb), width: 1.5)),
            ),
            items: users.map((u) => DropdownMenuItem(value: u, child: Text(u.name, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (u) => setState(() => selected = u),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pin, obscureText: !showPin, keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xff092d50)),
              hintText: translateEnglish('Password / PIN'),
              suffixIcon: IconButton(onPressed: () => setState(() => showPin = !showPin), icon: Icon(showPin ? Icons.visibility : Icons.visibility_off, color: const Color(0xff59647a))),
              filled: true, fillColor: const Color(0xfff7f9fc),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xffc5cedb), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onSubmitted: (_) => enter(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xff17a31c), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: enter,
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.login_rounded, size: 30), SizedBox(width: 10),
                Text('Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ]),
      ),
    );

    final features = Row(children: [
      _loginFeature(Icons.warehouse_rounded, 'Multiple\nWarehouses'),
      _loginDivider(),
      _loginFeature(Icons.fact_check_rounded, 'Track\nMovements'),
      _loginDivider(),
      _loginFeature(Icons.bar_chart_rounded, 'Control\nInventory'),
      _loginDivider(),
      _loginFeature(Icons.verified_user_rounded, 'Secure\nAccess'),
    ]);

    final footer = Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: const Color(0xff062a50), borderRadius: BorderRadius.circular(14)),
      child: const Column(children: [
        Text('StockPro by Monier © 2026', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('Together for a Smarter Business', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13)),
      ]),
    );

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
      children: [
        const MonierBrand(size: 82),
        const SizedBox(height: 4),
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Stock', style: TextStyle(color: Color(0xff092d50), fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
          TextSpan(text: 'Pro', style: TextStyle(color: Color(0xff19a52b), fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
        ])),
        const Text('Inventory • Operations • Better Control', style: TextStyle(color: Color(0xff092d50), fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('By Monier', style: TextStyle(color: Color(0xff092d50), fontSize: 21, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        loginCard,
        const SizedBox(height: 12),
        features,
        const SizedBox(height: 12),
        footer,
      ],
    );

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xfff5f8fc), Color(0xffffffff), Color(0xffe9f0f7)])))),
        Positioned(top: -100, left: -100, child: Container(width: 260, height: 260, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff159b20)))),
        Positioned(top: -80, left: -70, child: Container(width: 220, height: 220, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff0b3970)))),
        Positioned(bottom: -90, right: -80, child: Container(width: 270, height: 270, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff062a50)))),
        Positioned(bottom: -110, right: -80, child: Container(width: 225, height: 225, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff21a447)))),
        SafeArea(
          child: LayoutBuilder(builder: (ctx, box) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width < 380 ? 14 : 24, vertical: 18),
                      child: content,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
  Widget _loginFeature(IconData icon,String text)=>Expanded(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(icon,color:const Color(0xff092d50),size:34),const SizedBox(height:3),Text(text,textAlign:TextAlign.center,style:const TextStyle(color:Color(0xff092d50),fontSize:11.5,fontWeight:FontWeight.w600))]));
  Widget _loginDivider()=>Container(height:52,width:2,color:const Color(0xff20a638),margin:const EdgeInsets.symmetric(horizontal:3));
}
class AnimatedSplash extends StatefulWidget {const AnimatedSplash({super.key});@override State<AnimatedSplash> createState()=>_AnimatedSplashState();}
class _AnimatedSplashState extends State<AnimatedSplash> with TickerProviderStateMixin {
  late final AnimationController _intro=AnimationController(vsync:this,duration:const Duration(milliseconds:900));
  late final AnimationController _shine=AnimationController(vsync:this,duration:const Duration(milliseconds:1000));
  late final Animation<double> _scale=CurvedAnimation(parent:_intro,curve:Curves.easeOutBack);
  late final Animation<double> _fade=CurvedAnimation(parent:_intro,curve:Curves.easeOut);
  @override void initState(){super.initState();_intro.forward();_shine.repeat();Future.delayed(const Duration(milliseconds:2200),(){if(!mounted)return;Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>const LoginScreen()));});}
  @override void dispose(){_intro.dispose();_shine.dispose();super.dispose();}
  @override Widget build(BuildContext c) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xff063f36), Color(0xff006b5b), Color(0xff073d35)]),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MonierBrand(size: 100, light: true),
                  SizedBox(height: 10),
                  Text('StockPro Business', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Catering • Inventory • Site Operations', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Site{String name,client;double b,l,d;Site(this.name,this.client,this.b,this.l,this.d);Map j()=>{'n':name,'c':client,'b':b,'l':l,'d':d};}
class Day{String site;DateTime date;int b,l,d,e;String id;Day(this.site,this.date,this.b,this.l,this.d,this.e,{String? id}):id=id??DateTime.now().microsecondsSinceEpoch.toString();Map j()=>{'s':site,'t':date.toIso8601String(),'b':b,'l':l,'d':d,'e':e,'id':id};}
class Item{String n,code,unit;double cost,q,min;Item(this.n,this.code,this.unit,this.cost,this.q,this.min);Map j()=>{'n':n,'c':code,'u':unit,'cost':cost,'q':q,'min':min};}
class Movement{String item,type,note,warehouse,ref;double qty;DateTime date;double? unitCost;Movement(this.item,this.type,this.qty,this.note,this.date,[this.warehouse='',this.ref='',this.unitCost]);Map j()=>{'i':item,'t':type,'q':qty,'n':note,'d':date.toIso8601String(),'w':warehouse,'ref':ref,'cost':unitCost};}
class Recipe{String item,meal;double qty;Recipe(this.item,this.meal,this.qty);Map j()=>{'i':item,'m':meal,'q':qty};}
class Warehouse{String name,site,manager;bool main;Warehouse(this.name,this.site,this.manager,this.main);Map j()=>{'n':name,'s':site,'m':manager,'main':main};}
class Expense{String id,site,category,note;DateTime date;double amount;Expense(this.id,this.site,this.category,this.note,this.date,this.amount);Map j()=>{'id':id,'s':site,'c':category,'n':note,'d':date.toIso8601String(),'a':amount};factory Expense.fromMap(dynamic x)=>Expense(x['id']??DateTime.now().microsecondsSinceEpoch.toString(),x['s']??'',x['c']??'أخرى',x['n']??'',DateTime.tryParse(x['d']??'')??DateTime.now(),(x['a'] as num?)?.toDouble()??0);}
class AppUser {
  String name, pin;
  bool admin;
  Set<String> permissions; Set<String> sites; Set<String> warehouses;
  AppUser(this.name,this.pin,this.admin,this.permissions,[Set<String>? sites,Set<String>? warehouses]):sites=sites??{},warehouses=warehouses??{};
  Map j()=>{'n':name,'pin':pin,'admin':admin,'p':permissions.toList(),'sites':sites.toList(),'warehouses':warehouses.toList()};
  static const modules=['الرئيسية','المواقع','الوجبات','المخزون','التقارير','المخازن','المصروفات'];
}
class AuditEntry{String user,action,entity,details;DateTime date;AuditEntry(this.user,this.action,this.entity,this.details,this.date);Map j()=>{'u':user,'a':action,'e':entity,'d':details,'t':date.toIso8601String()};factory AuditEntry.fromMap(dynamic x)=>AuditEntry(x['u']??'',x['a']??'',x['e']??'',x['d']??'',DateTime.tryParse(x['t']??'')??DateTime.now());}
class Hub extends StatefulWidget{const Hub({super.key});@override State<Hub> createState()=>HState();}
class HState extends State<Hub>{RealtimeChannel? _companyRealtimeChannel; bool _companyRealtimeStarted=false;int tab=0;bool ready=false;DateTime reportFrom=DateTime(DateTime.now().year,DateTime.now().month,1);DateTime reportTo=DateTime.now();final sites=<Site>[];final days=<Day>[];final items=<Item>[];final movements=<Movement>[];final recipes=<Recipe>[];final warehouses=<Warehouse>[];final users=<AppUser>[];final auditLogs=<AuditEntry>[];final expenses=<Expense>[];final stockBalances=<String,Map<String,double>>{};String activeUser='المدير';double wasteAlertThreshold=5;Map<String,dynamic> wasteAlertReviews={};AppUser get current=>users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{}));List<Site> get visibleSites=>current.admin?sites:sites.where((s)=>current.sites.contains(s.name)).toList();List<Warehouse> get visibleWarehouses=>current.admin?warehouses:warehouses.where((w)=>current.warehouses.contains(w.name)).toList();List<Day> get visibleDays=>current.admin?days:days.where((x)=>current.sites.contains(x.site)).toList();List<Movement> get visibleMovements=>current.admin?movements:movements.where((m)=>current.warehouses.contains(m.warehouse)).toList();List<Item> get visibleItems=>current.admin||visibleWarehouses.isNotEmpty?items:[];double visibleBalance(Item item)=>visibleWarehouses.fold(0.0,(sum,w)=>sum+balance(item,w.name));double get visibleStock=>visibleItems.fold(0.0,(sum,item)=>sum+visibleBalance(item)*item.cost);int get visibleLowStockCount=>visibleItems.where((item)=>visibleBalance(item)<=item.min).length;
Future<void> load()async{final p=await SharedPreferences.getInstance();sites.clear();days.clear();items.clear();movements.clear();recipes.clear();warehouses.clear();users.clear();auditLogs.clear();expenses.clear();stockBalances.clear();try{sites.addAll((jsonDecode(p.getString('sites')??'[]') as List).map((x)=>Site(x['n'],x['c'],(x['b'] as num).toDouble(),(x['l'] as num).toDouble(),(x['d'] as num).toDouble())));days.addAll((jsonDecode(p.getString('days')??'[]') as List).map((x)=>Day(x['s'],DateTime.parse(x['t']),x['b'],x['l'],x['d'],x['e'],id:x['id']??'')));items.addAll((jsonDecode(p.getString('items')??'[]') as List).map((x)=>Item(x['n'],x['c'],x['u'],(x['cost'] as num).toDouble(),(x['q'] as num).toDouble(),(x['min'] as num).toDouble())));movements.addAll((jsonDecode(p.getString('movements')??'[]') as List).map((x)=>Movement(x['i'],x['t'],(x['q'] as num).toDouble(),x['n'],DateTime.parse(x['d']),x['w']??'',x['ref']??'',(x['cost'] as num?)?.toDouble())));recipes.addAll((jsonDecode(p.getString('recipes')??'[]') as List).map((x)=>Recipe(x['i'],x['m'],(x['q'] as num).toDouble())));warehouses.addAll((jsonDecode(p.getString('warehouses')??'[]') as List).map((x)=>Warehouse(x['n'],x['s']??'',x['m']??'',x['main']??false)));users.addAll((jsonDecode(p.getString('users')??'[]') as List).map((x)=>AppUser(x['n'],x['pin']??'',x['admin']??false,Set<String>.from(x['p']??AppUser.modules),Set<String>.from(x['sites']??[]),Set<String>.from(x['warehouses']??[]))));
auditLogs.addAll((jsonDecode(p.getString('auditLogs')??'[]') as List).map((x)=>AuditEntry.fromMap(x)));expenses.addAll((jsonDecode(p.getString('expenses')??'[]') as List).map((x)=>Expense.fromMap(x)));activeUser=p.getString('activeUser')??'المدير';final rawThreshold=p.get('wasteAlertThreshold');wasteAlertThreshold=(rawThreshold is num?rawThreshold.toDouble():double.tryParse(rawThreshold?.toString()??'')??5).clamp(1,100).toDouble();try{final rawReviews=jsonDecode(p.getString('wasteAlertReviews')??'{}');if(rawReviews is Map)wasteAlertReviews=Map<String,dynamic>.from(rawReviews);}catch(_){}
if(users.isEmpty){users.add(AppUser('المدير','',true,Set<String>.from(AppUser.modules)));}
if(!users.any((u)=>u.name==activeUser))activeUser=users.first.name;
if(warehouses.isEmpty){warehouses.add(Warehouse('المخزن الرئيسي','كل الشركة','',true));}final raw=jsonDecode(p.getString('stockBalances')??'{}');if(raw is Map){raw.forEach((wh,v){if(v is Map)stockBalances[wh.toString()]=v.map((k,val)=>MapEntry(k.toString(),(val as num).toDouble()));});}final main=warehouses.firstWhere((w)=>w.main,orElse:()=>warehouses.first);stockBalances.putIfAbsent(main.name,()=>{});for(final item in items){stockBalances[main.name]!.putIfAbsent(item.n,()=>item.q);item.q=stockBalances[main.name]![item.n]??0;}}catch(_){if(users.isEmpty)users.add(AppUser('المدير','',true,Set<String>.from(AppUser.modules)));}setState(()=>ready=true);_startCompanyRealtime();}
Timer? _cloudSyncTimer;
bool _cloudSyncing=false;
Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('sites',jsonEncode(sites.map((x)=>x.j()).toList()));await p.setString('days',jsonEncode(days.map((x)=>x.j()).toList()));await p.setString('items',jsonEncode(items.map((x)=>x.j()).toList()));await p.setString('movements',jsonEncode(movements.map((x)=>x.j()).toList()));await p.setString('recipes',jsonEncode(recipes.map((x)=>x.j()).toList()));await p.setString('warehouses',jsonEncode(warehouses.map((x)=>x.j()).toList()));await p.setString('stockBalances',jsonEncode(stockBalances));await p.setString('users',jsonEncode(users.map((x)=>x.j()).toList()));await p.setString('activeUser',activeUser);await p.setString('auditLogs',jsonEncode(auditLogs.map((x)=>x.j()).toList()));await p.setString('expenses',jsonEncode(expenses.map((x)=>x.j()).toList()));_queueCloudBackup();}
void _queueCloudBackup(){_cloudSyncTimer?.cancel();_cloudSyncTimer=Timer(const Duration(seconds:3),_autoCloudBackup);}
Future<void> _startCompanyRealtime() async { if(_companyRealtimeStarted || !CloudConnection.initialized) return; _companyRealtimeStarted=true; try { final client=Supabase.instance.client; final user=client.auth.currentUser; final p=await SharedPreferences.getInstance(); final companyId=p.getString('cloudCompanyId'); final linkedUser=p.getString('cloudCompanyUserId'); if(user==null || companyId==null || companyId.isEmpty || linkedUser!=user.id){_companyRealtimeStarted=false;return;} _companyRealtimeChannel=client.channel('stockpro-company-$companyId').onPostgresChanges(event:PostgresChangeEvent.all,schema:'public',table:'company_data_snapshots',filter:PostgresChangeFilter(type:PostgresChangeFilterType.eq,column:'company_id',value:companyId),callback:(payload) async { final row=payload.newRecord; final revision=int.tryParse(row['revision']?.toString()??'')??0; final prefs=await SharedPreferences.getInstance(); final baseline=prefs.getInt('cloudSharedRevisionBaseline'); if(revision<= (baseline??0) || !mounted) return; if(_cloudSyncing || (_cloudSyncTimer?.isActive??false)){await prefs.setString('cloudSharedSyncStatus','وصل تحديث Revision $revision لكن عندك تغييرات محلية قيد الحفظ؛ تم تأجيل التنزيل لتجنب فقدها.'); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('تحديث من الجهاز الآخر مؤجل لحماية تعديلاتك المحلية.')))); return;} if(baseline==null){await prefs.setString('cloudSharedSyncStatus','وصل تحديث Revision $revision. يلزم تنزيل أول نسخة يدويًا لمقارنة البيانات المحلية بأمان.'); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(seconds:8),content:Text(translateEnglish('وصل تحديث من الجهاز الآخر. نزّل النسخة الأولى يدويًا لتفعيل التحديث التلقائي.')))); return;} try { final response=await client.rpc('get_company_snapshot',params:{'target_company':companyId}); if(response is! List || response.isEmpty) return; final cloudRow=response.first as Map; final remoteRevision=int.tryParse(cloudRow['revision'].toString())??0; if(remoteRevision<=baseline) return; final payload=cloudRow['payload']; if(payload is! Map || payload['app']!='StockPro' || payload['schema']!=1) throw Exception('نسخة سحابية غير متوافقة'); final keys=['sites','days','items','movements','recipes','warehouses','stockBalances','auditLogs','expenses','wasteAlertThreshold','wasteAlertReviews']; final backup=<String,dynamic>{'createdAt':DateTime.now().toIso8601String()}; for(final key in keys){backup[key]=prefs.get(key);} await prefs.setString('cloudRestoreSafetyBackup',jsonEncode(backup)); for(final key in keys){if(payload.containsKey(key)){final value=payload[key];if(value==null){await prefs.remove(key);}else if(value is String){await prefs.setString(key,value);}else{await prefs.setString(key,jsonEncode(value));}}} await prefs.setInt('cloudSharedRevisionBaseline',remoteRevision); await prefs.setString('cloudSharedSyncStatus','تم تنزيل تحديث تلقائي من جهاز آخر — Revision $remoteRevision'); await load(); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('تمت مزامنة تحديث الجهاز الآخر تلقائيًا — Revision $remoteRevision'))));} catch(e){await prefs.setString('cloudSharedSyncStatus','وصل تحديث لكن تعذر تنزيله تلقائيًا: $e'); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('وصل تحديث لكن لم يتم تنزيله؛ راجع صفحة الكلاود.'))));} }).subscribe(); } catch(_) { _companyRealtimeStarted=false; } }
Future<void> _autoCloudBackup()async{if(_cloudSyncing||!CloudConnection.initialized)return;final client=Supabase.instance.client;final user=client.auth.currentUser;if(user==null)return;final p=await SharedPreferences.getInstance();final companyId=p.getString('cloudCompanyId');final linkedUser=p.getString('cloudCompanyUserId');if(companyId==null||companyId.isEmpty||linkedUser!=user.id)return;_cloudSyncing=true;try{const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','users','activeUser','auditLogs','expenses','wasteAlertThreshold','wasteAlertReviews'];final snapshot=<String,dynamic>{'app':'StockPro','schema':1,'savedAt':DateTime.now().toIso8601String()};for(final key in keys){snapshot[key]=p.get(key);}try{await client.rpc('save_user_snapshot',params:{'target_company':companyId,'snapshot':snapshot});await p.setString('cloudLastAutoSync',DateTime.now().toIso8601String());}catch(e){await p.setString('cloudSnapshotSyncStatus','تعذر تحديث النسخة الشخصية: $e');}const sharedKeys=['sites','days','items','movements','recipes','warehouses','stockBalances','auditLogs','expenses','wasteAlertThreshold','wasteAlertReviews'];final sharedSnapshot=<String,dynamic>{'app':'StockPro','schema':1,'savedAt':DateTime.now().toIso8601String()};for(final key in sharedKeys){sharedSnapshot[key]=p.get(key);}await _autoCompanySync(client,p,companyId,sharedSnapshot);}catch(e){await p.setString('cloudSharedSyncStatus','تعذر بدء المزامنة: $e');}finally{_cloudSyncing=false;}}
Future<void> _autoCompanySync(SupabaseClient client,SharedPreferences p,String companyId,Map<String,dynamic> snapshot)async{try{final rows=await client.rpc('get_company_snapshot',params:{'target_company':companyId});final remoteRevision=rows is List&&rows.isNotEmpty?(int.tryParse((rows.first as Map)['revision'].toString())??0):0;final baseline=p.getInt('cloudSharedRevisionBaseline');if(baseline==null&&remoteRevision>0){await p.setString('cloudSharedSyncStatus','توجد بيانات مشتركة أحدث أو لم يتم تنزيلها بعد؛ تم إيقاف الرفع التلقائي لحماية البيانات.');return;}if(baseline!=null&&remoteRevision!=baseline){await p.setString('cloudSharedSyncStatus','تعارض مزامنة: نسخة الشركة تغيرت على جهاز آخر. نزّل النسخة المشتركة قبل أي رفع جديد.');return;}final expected=baseline??0;final next=await client.rpc('save_company_snapshot',params:{'target_company':companyId,'snapshot':snapshot,'expected_revision':expected});final revision=int.tryParse(next.toString())??expected+1;await p.setInt('cloudSharedRevisionBaseline',revision);await p.setString('cloudSharedSyncStatus','تمت المزامنة التلقائية لبيانات الشركة — Revision $revision');await p.setString('cloudSharedLastAutoSync',DateTime.now().toIso8601String());}catch(e){await p.setString('cloudSharedSyncStatus','المزامنة التلقائية متوقفة: '+e.toString());}}
void addAudit(String action,String entity,String details){auditLogs.insert(0,AuditEntry(activeUser,action,entity,details,DateTime.now()));if(auditLogs.length>1000)auditLogs.removeRange(1000,auditLogs.length);}
@override void initState(){super.initState();load();}
bool today(DateTime d){final n=DateTime.now();return d.year==n.year&&d.month==n.month&&d.day==n.day;}
double rev(Day x){final s=sites.where((z)=>z.name==x.site);return s.isEmpty?0:x.b*s.first.b+x.l*s.first.l+x.d*s.first.d;}
int get mealTotal=>days.where((x)=>today(x.date)).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e);
double get revToday=>days.where((x)=>today(x.date)).fold(0.0,(a,x)=>a+rev(x));
double get stock=>items.fold(0.0,(a,x)=>a+x.q*x.cost);
bool can(String module)=>users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).admin||users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).permissions.contains(module);void siteAdd(Site x){setState(()=>sites.add(x));save();}void dayAdd(Day x){setState(()=>days.add(x));save();}void itemAdd(Item x){stockBalances.putIfAbsent(mainWarehouse.name,()=>{});stockBalances[mainWarehouse.name]![x.n]=x.q;setState(()=>items.add(x));save();}Warehouse get mainWarehouse=>warehouses.firstWhere((w)=>w.main,orElse:()=>warehouses.first);double balance(Item item,String warehouse)=>stockBalances[warehouse]?[item.n]??0;void setBalance(Item item,String warehouse,double value){stockBalances.putIfAbsent(warehouse,()=>{});stockBalances[warehouse]![item.n]=value;if(warehouse==mainWarehouse.name)item.q=value;}
 double movementCost(Movement m){final item=items.firstWhere((i)=>i.n==m.item,orElse:()=>Item(m.item,'','',0,0,0));return m.qty*(m.unitCost??item.cost);}
 String? movementSite(Movement m){if(m.type=='استهلاك وجبات'&&m.note.startsWith('موقع: '))return m.note.substring(6).split(' • ').first.trim();final wh=warehouses.where((w)=>w.name==m.warehouse).firstOrNull;if(wh!=null&&!wh.main&&wh.site.isNotEmpty&&wh.site!='كل الشركة')return wh.site;return null;}
 bool isSiteConsumption(Movement m){if(m.type=='استهلاك وجبات'||m.type=='صرف للموقع')return true;if(m.type=='صرف'){final wh=warehouses.where((w)=>w.name==m.warehouse).firstOrNull;return wh!=null&&!wh.main&&wh.site.isNotEmpty&&wh.site!='كل الشركة';}return false;}
 List<Movement> siteCostMovements(String site,DateTime from,DateTime to){final start=DateTime(from.year,from.month,from.day),end=DateTime(to.year,to.month,to.day);return movements.where((m){final d=DateTime(m.date.year,m.date.month,m.date.day);return isSiteConsumption(m)&&movementSite(m)==site&&!d.isBefore(start)&&!d.isAfter(end);}).toList();}
 double siteMaterialCost(String site,DateTime from,DateTime to)=>siteCostMovements(site,from,to).fold<double>(0,(sum,m)=>sum+movementCost(m));
 double linkedDayMaterialCost(String dayId)=>movements.where((m)=>m.ref==dayId&&m.type=='استهلاك وجبات').fold<double>(0,(sum,m)=>sum+movementCost(m));
 Map<Item,double> expectedSiteConsumption(String site,DateTime from,DateTime to){final start=DateTime(from.year,from.month,from.day),end=DateTime(to.year,to.month,to.day);final result=<Item,double>{};for(final day in days){final date=DateTime(day.date.year,day.date.month,day.date.day);if(day.site!=site||date.isBefore(start)||date.isAfter(end))continue;for(final recipe in recipes){final count=recipe.meal=='إفطار'?day.b:recipe.meal=='غداء'?day.l:recipe.meal=='عشاء'?day.d:0;if(count<=0)continue;final item=items.where((i)=>i.n==recipe.item).firstOrNull;if(item!=null)result[item]=(result[item]??0)+count*recipe.qty;}}return result;}
 List<Movement> manualSiteIssueMovements(String site,DateTime from,DateTime to){final start=DateTime(from.year,from.month,from.day),end=DateTime(to.year,to.month,to.day);return movements.where((m){final date=DateTime(m.date.year,m.date.month,m.date.day);if(date.isBefore(start)||date.isAfter(end)||movementSite(m)!=site)return false;if(m.type=='استهلاك وجبات')return false;return m.type=='صرف للموقع'||m.type=='صرف';}).toList();}
 Map<Item,double> actualSiteIssues(String site,DateTime from,DateTime to){final result=<Item,double>{};for(final m in manualSiteIssueMovements(site,from,to)){final item=items.where((i)=>i.n==m.item).firstOrNull;if(item!=null)result[item]=(result[item]??0)+m.qty;}return result;}
@override void dispose(){_cloudSyncTimer?.cancel();final channel=_companyRealtimeChannel;if(channel!=null){Supabase.instance.client.removeChannel(channel);}super.dispose();}
  Future<void> showLanguageDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(translateEnglish('🌐 Language / اللغة')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Text('🇪🇬', style: TextStyle(fontSize: 24)),
            title: Text(translateEnglish('العربية')),
            subtitle: Text(translateEnglish('Right-to-left (RTL)')),
            trailing: appLanguage.value == 'ar' ? const Icon(Icons.check_circle, color: Colors.teal) : null,
            onTap: () async {
              appLanguage.value = 'ar';
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('appLanguage', 'ar');
              if (mounted) setState(() {});
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
          ListTile(
            leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
            title: Text(translateEnglish('English')),
            subtitle: Text(translateEnglish('Left-to-right (LTR)')),
            trailing: appLanguage.value == 'en' ? const Icon(Icons.check_circle, color: Colors.teal) : null,
            onTap: () async {
              appLanguage.value = 'en';
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('appLanguage', 'en');
              if (mounted) setState(() {});
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(languageText('إغلاق','Close')))],
      ),
    );
  }
@override
Widget build(BuildContext c) {
  if (!ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
  final views = <Widget Function()>[dashboard, sitePage, dayPage, itemPage, reportPage, warehousePage, userPage, expensePage];
  final allowedTabs = [0,1,2,3,4,5,6,7].where((i) {
    if (i == 6) return current.admin;
    if (i == 7) return can('المصروفات');
    return can(AppUser.modules[i]);
  }).toList();
  if (!allowedTabs.contains(tab)) tab = allowedTabs.isEmpty ? 0 : allowedTabs.first;
  final icons = [Icons.home,Icons.apartment,Icons.restaurant,Icons.inventory,Icons.analytics,Icons.warehouse,Icons.people,Icons.receipt_long];
  final labels = appLanguage.value == 'en' ? ['Home','Sites','Meals','Inventory','Reports','Warehouses','Users','Expenses'] : ['الرئيسية','المواقع','الوجبات','المخزون','التقارير','المخازن','المستخدمون','المصروفات'];
  final colors = Theme.of(c).colorScheme;
  return Directionality(
    textDirection: appLanguage.value == 'en' ? TextDirection.ltr : TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const MonierBrand(size: 27), const SizedBox(width: 6),
          Flexible(child: Text(languageText('StockPro | التغذية', 'StockPro | Catering'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
        ]),
        actions: [
          IconButton(tooltip: languageText('تغيير اللغة', 'Change language'), icon: const Icon(Icons.language), onPressed: showLanguageDialog),
          IconButton(tooltip: translateEnglish('حول StockPro'), icon: Icon(Icons.info_outline), onPressed: showStockProAbout),
          IconButton(tooltip: translateEnglish('تسجيل الخروج'), icon: Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()))),
        ],
      ),
      body: views[tab](),
      bottomNavigationBar: allowedTabs.isEmpty ? const SizedBox.shrink() : SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xffe5eceb)))),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(children: allowedTabs.map((i) {
              final selected = i == tab;
              return InkWell(
                onTap: () => setState(() => tab = i),
                child: Container(
                  width: 78, height: 68,
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(color: selected ? colors.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                    Icon(icons[i], size: 23, color: selected ? colors.primary : const Color(0xff455453)),
                    const SizedBox(height: 3),
                    Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? colors.primary : const Color(0xff455453))),
                  ]),
                ),
              );
            }).toList()),
          ),
        ),
      ),
    ),
  );
}
Future<void> expenseDialog({Expense? existing}) async {
  if (visibleSites.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('سجل المواقع أولاً'))));
    return;
  }
  final categories = ['عمالة', 'نقل', 'إقامة', 'مصروفات الموقع', 'صيانة', 'أخرى'];
  Site chosen = visibleSites.firstWhere((s) => s.name == existing?.site, orElse: () => visibleSites.first);
  String category = categories.contains(existing?.category) ? existing!.category : 'أخرى';
  DateTime date = existing?.date ?? DateTime.now();
  final amount = TextEditingController(text: existing?.amount.toString() ?? '');
  final note = TextEditingController(text: existing?.note ?? '');
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, refresh) => AlertDialog(
        title: Text(existing == null ? 'إضافة مصروف' : 'تعديل مصروف'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<Site>(
              value: chosen,
              decoration: InputDecoration(labelText: translateEnglish('الموقع')),
              items: visibleSites.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (v) { if (v != null) refresh(() => chosen = v); },
            ),
            DropdownButtonFormField<String>(
              value: category,
              decoration: InputDecoration(labelText: translateEnglish('نوع المصروف')),
              items: categories.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (v) { if (v != null) refresh(() => category = v); },
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(context: dialogContext, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (picked != null) refresh(() => date = picked);
              },
              icon: const Icon(Icons.date_range),
              label: Text(translateEnglish('التاريخ: ${reportDateText(date)}')),
            ),
            field(amount, translateEnglish('المبلغ بالجنيه'), numeric: true),
            field(note, translateEnglish('ملاحظات')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(translateEnglish('إلغاء'))),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amount.text.trim().replaceAll(',', '.')) ?? 0;
              if (value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('أدخل مبلغ صحيح'))));
                return;
              }
              if (existing == null) {
                expenses.add(Expense(DateTime.now().microsecondsSinceEpoch.toString(), chosen.name, category, note.text.trim(), date, value));
                addAudit('إضافة', 'مصروف', chosen.name + ' • ' + category + ' • ' + cash(value));
              } else {
                existing.site = chosen.name;
                existing.category = category;
                existing.note = note.text.trim();
                existing.date = date;
                existing.amount = value;
                addAudit('تعديل', 'مصروف', chosen.name + ' • ' + category + ' • ' + cash(value));
              }
              save();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: Text(translateEnglish('حفظ')),
          ),
        ],
      ),
    ),
  );
}
Future<void> deleteExpense(Expense x)async{final ok=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:Text(translateEnglish('حذف المصروف')),content:Text(translateEnglish('حذف مصروف ${cash(x.amount)} — ${x.site}؟')),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:Text(translateEnglish('حذف')))]));if(ok==true){expenses.remove(x);addAudit('حذف','مصروف',x.site+' • '+cash(x.amount));await save();if(mounted)setState((){});}}
Widget expensePage()=>ListView(padding:EdgeInsets.all(12),children:[Row(children:[Expanded(child:Text('مصروفات المواقع',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:expenseDialog,icon:Icon(Icons.add),label:Text(translateEnglish('مصروف جديد')))]),metric('إجمالي مصروفات المواقع',cash(expenses.where((x)=>current.admin||current.sites.contains(x.site)).fold<double>(0.0,(double a,Expense x)=>a+x.amount)),Icons.receipt_long),...expenses.where((x)=>current.admin||current.sites.contains(x.site)).toList().reversed.map((x)=>Card(child:ListTile(title:Text(x.site+' • '+x.category),subtitle:Text(reportDateText(x.date)+(x.note.isEmpty?'':'\n'+x.note)),leading:Icon(Icons.money_off),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(cash(x.amount)),IconButton(icon:Icon(Icons.edit),onPressed:()=>expenseDialog(existing:x)),IconButton(icon:Icon(Icons.delete_outline,color:Colors.red),onPressed:()=>deleteExpense(x))]))))]);
Widget userPage()=>ListView(padding:EdgeInsets.all(12),children:[Row(children:[Expanded(child:Text('المستخدمون والصلاحيات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:userDialog,icon:Icon(Icons.person_add),label:Text(translateEnglish('إضافة مستخدم'))),if(current.admin)OutlinedButton.icon(onPressed:auditLogDialog,icon:Icon(Icons.history),label:Text(translateEnglish('سجل التدقيق')))]),Card(child:ListTile(leading:Icon(Icons.account_circle),title:Text(translateEnglish('المستخدم الحالي')),subtitle:Text(activeUser),trailing:Icon(Icons.verified_user,color:Colors.teal))),Card(child:ListTile(title:Text(translateEnglish('أمان الدخول')),subtitle:Text(translateEnglish('تغيير المستخدم يتم بعد تسجيل الخروج وإدخال PIN الخاص به. الحسابات والصلاحيات محلية على هذا الجهاز.')))),...users.map((u)=>Card(child:ListTile(leading:Icon(u.admin?Icons.admin_panel_settings:Icons.person),title:Text(u.name),subtitle:Text(u.admin?'مدير — صلاحيات كاملة':'صلاحيات: '+u.permissions.join('، ')),trailing:IconButton(icon:Icon(Icons.edit),onPressed:()=>userDialog(existing:u)))))]); 
Future<void> userDialog({AppUser? existing})async{
  final name=TextEditingController(text:existing?.name??'');final pin=TextEditingController(text:existing?.pin??'');bool admin=existing?.admin??false;
  final perms=Set<String>.from(existing?.permissions??{});final siteScope=Set<String>.from(existing?.sites??{});final warehouseScope=Set<String>.from(existing?.warehouses??{});
  await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(
    title:Text(existing==null?'إضافة مستخدم':'تعديل المستخدم'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      field(name, translateEnglish('اسم المستخدم')),field(pin, translateEnglish('رقم PIN (إجباري)'),numeric:true,decimal:false),
      CheckboxListTile(value:admin,title:Text(translateEnglish('مدير — صلاحيات كاملة')),onChanged:(v)=>set(()=>admin=v??false)),
      Divider(),...AppUser.modules.map((m)=>CheckboxListTile(dense:true,value:perms.contains(m),title:Text(translateEnglish('السماح بـ $m')),onChanged:(v)=>set(()=>v==true?perms.add(m):perms.remove(m)))),
      Divider(),Text(translateEnglish('المواقع المسموح بها')),...sites.map((site)=>CheckboxListTile(dense:true,value:siteScope.contains(site.name),title:Text(site.name),onChanged:(v)=>set(()=>v==true?siteScope.add(site.name):siteScope.remove(site.name)))),
      Text(translateEnglish('المخازن المسموح بها')),...warehouses.map((wh)=>CheckboxListTile(dense:true,value:warehouseScope.contains(wh.name),title:Text(wh.name),onChanged:(v)=>set(()=>v==true?warehouseScope.add(wh.name):warehouseScope.remove(wh.name))))
    ])),
    actions:[TextButton(onPressed:()=>Navigator.pop(x),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:(){
      if(name.text.trim().isEmpty||pin.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('اسم المستخدم والـ PIN مطلوبان'))));return;}
      if(existing==null){if(users.any((u)=>u.name==name.text.trim())){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('اسم المستخدم موجود بالفعل'))));return;}users.add(AppUser(name.text.trim(),pin.text.trim(),admin,Set<String>.from(perms),Set<String>.from(siteScope),Set<String>.from(warehouseScope)));}
      else{existing.name=name.text.trim();existing.pin=pin.text.trim();existing.admin=admin;existing.permissions=Set<String>.from(perms);existing.sites=Set<String>.from(siteScope);existing.warehouses=Set<String>.from(warehouseScope);}
      addAudit(existing==null?'إضافة':'تعديل','مستخدم',name.text.trim());save();setState((){});Navigator.pop(x);
    },child:Text(translateEnglish('حفظ')))])));
}
Future<void> auditLogDialog()async{final search=TextEditingController();await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,refresh){final q=search.text.trim().toLowerCase();final list=auditLogs.where((x)=>q.isEmpty||[x.user,x.action,x.entity,x.details].join(' ').toLowerCase().contains(q)).toList();return AlertDialog(title:Text(translateEnglish('سجل التدقيق')),content:SizedBox(width:480,height:480,child:Column(children:[TextField(controller:search,decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'بحث بالمستخدم أو العملية أو التفاصيل'),onChanged:(_)=>refresh((){})),SizedBox(height:8),Expanded(child:list.isEmpty?Center(child:Text(translateEnglish('لا توجد سجلات'))):ListView.builder(itemCount:list.length,itemBuilder:(c,i){final x=list[i];return ListTile(dense:true,leading:Icon(Icons.history),title:Text(translateEnglish('${x.action} • ${x.entity}')),subtitle:Text(translateEnglish('${x.user} | ${x.date.toLocal()}\n${x.details}')));}))])),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:Text(translateEnglish('إغلاق')))]);}));}
Future<void> showStockProAbout() async {
  await showDialog<void>(
    context: context,
    builder: (dc) => AlertDialog(
      title: Text(translateEnglish('StockPro Business')),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(translateEnglish('إدارة مواقع التغذية والمخازن والوجبات والمصروفات في مكان واحد.')),
            SizedBox(height: 12),
            Text('المميزات الحالية', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(translateEnglish('• إدارة المواقع والعقود وتسجيل الوجبات اليومية.')),
            Text(translateEnglish('• مخازن مستقلة وتحويلات وجرد وتسويات.')),
            Text(translateEnglish('• وصفات واستهلاك خامات وتقارير ومصروفات.')),
            Text(translateEnglish('• مستخدمون وصلاحيات وسجل تدقيق.')),
            Text(translateEnglish('• استيراد Excel ونسخ احتياطي واستعادة.')),
            SizedBox(height: 12),
            Text('حالة البيانات والخصوصية', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(translateEnglish('في هذه النسخة، البيانات محفوظة محليًا على الجهاز. لا توجد مزامنة سحابية أو مشاركة تلقائية بين الأجهزة. النسخ الاحتياطي مسؤولية المستخدم ويُنصح بإنشاء نسخة دورية وحفظها في مكان آمن.')),
            SizedBox(height: 8),
            Text(translateEnglish('حسابات المستخدمين وPIN محلية على الجهاز. تم تجهيز اتصال Supabase تجريبي، لكن مزامنة البيانات وتسجيل الدخول السحابي لم يتم تفعيلهما بعد.')),
            SizedBox(height: 12),
            Text('إعداد الكلاود', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(translateEnglish('زر فحص الاتصال يتحقق من الوصول إلى قاعدة StockPro فقط، ولا ينقل أو يرفع بيانات الجهاز.')),
            SizedBox(height: 12),
            Text('StockPro Business • إصدار تجهيز تجاري', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () async { Navigator.pop(dc); final result = await CloudConnection.checkDatabase(); if (mounted) { await showDialog<void>(context: context, builder: (x) => AlertDialog(title: Text(translateEnglish('فحص الكلاود')), content: Text(result), actions: [TextButton(onPressed: () => Navigator.pop(x), child: Text(translateEnglish('تمام')))])); } }, child: Text(translateEnglish('فحص الاتصال'))),
        FilledButton.icon(
          onPressed: () async {
            Navigator.pop(dc);
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CloudAccountScreen()));
            if (!mounted) return;
            // Cloud login/company linking may have changed the authenticated user
            // or company while this Hub was still alive. Rebind Realtime now.
            final oldChannel = _companyRealtimeChannel;
            if (oldChannel != null) {
              await Supabase.instance.client.removeChannel(oldChannel);
            }
            _companyRealtimeChannel = null;
            _companyRealtimeStarted = false;
            await load();
          },
          icon: const Icon(Icons.cloud),
          label: Text(translateEnglish('حساب الكلاود')),
        ),
        TextButton(onPressed: () => Navigator.pop(dc), child: Text(translateEnglish('إغلاق'))),
      ],
    ),
  );
}
Widget metric(String title, String val, IconData icon) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xffe6f4f1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xff087c68)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Color(0xff627574))),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xff153b3a))),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
List<Map<String,dynamic>> buildWasteAlerts(DateTime from,DateTime to,double threshold){
  final alerts=<Map<String,dynamic>>[];
  for(final site in visibleSites){
    final expected=expectedSiteConsumption(site.name,from,to);
    final actual=actualSiteIssues(site.name,from,to);
    for(final item in {...expected.keys,...actual.keys}){
      final e=expected[item]??0.0,a=actual[item]??0.0,d=a-e;
      if(e>0 && d>0 && d/e*100>=threshold){
        alerts.add({'site':site.name,'item':item,'expected':e,'actual':a,'difference':d,'percent':d/e*100,'cost':d*item.cost,'noRecipe':false});
      }else if(e<=0 && a>0){
        alerts.add({'site':site.name,'item':item,'expected':0.0,'actual':a,'difference':a,'percent':null,'cost':a*item.cost,'noRecipe':true});
      }
    }
  }
  for(final alert in alerts){final site=alert['site'] as String;final item=alert['item'] as Item;var occurrences=1;for(var offset=1;offset<=2;offset++){final start=DateTime(from.year,from.month-offset,1);final end=DateTime(start.year,start.month+1,0);occurrences+=wasteOccurrenceCount(site,item,start,end);}alert['repeatCount']=occurrences;}
  alerts.sort((a,b)=>(b['cost'] as double).compareTo(a['cost'] as double));
  return alerts;
}
Future<void> showWasteThresholdDialog() async {
  var selected=wasteAlertThreshold;
  final result=await showDialog<double>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setDialog)=>AlertDialog(
    title:Text(translateEnglish('حد تنبيه الانحراف')),
    content:Column(mainAxisSize:MainAxisSize.min,children:[
      Text('التنبيه عند تجاوز الاستهلاك المتوقع بنسبة ${selected.toStringAsFixed(0)}% أو أكثر',textAlign:TextAlign.center),
      Slider(min:1,max:30,divisions:29,value:selected,onChanged:(v)=>setDialog(()=>selected=v)),
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(translateEnglish('1%')),Text('${selected.toStringAsFixed(0)}%',style:TextStyle(fontWeight:FontWeight.bold,fontSize:20)),Text(translateEnglish('30%'))]),
    ]),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(ctx,selected),child:Text(translateEnglish('حفظ')))],
  )));
  if(result==null)return;
  wasteAlertThreshold=result;
  final prefs=await SharedPreferences.getInstance();
  await prefs.setDouble('wasteAlertThreshold',result);
  await save();
  if(mounted)setState((){});
}
String wasteReviewKey(Map<String,dynamic> alert,DateTime period){final item=alert['item'] as Item;return '${period.year}-${period.month.toString().padLeft(2,'0')}|${alert['site']}|${item.n}';}
Map<String,dynamic> wasteReviewFor(Map<String,dynamic> alert,DateTime period)=>wasteAlertReviews[wasteReviewKey(alert,period)]??{};
Future<void> reviewWasteAlert(Map<String,dynamic> alert,DateTime period)async{
 final item=alert['item'] as Item;final key=wasteReviewKey(alert,period);final old=wasteAlertReviews[key]??{};var reviewed=old['reviewed']==true;final note=TextEditingController(text:old['note']?.toString()??'');
 await showDialog<void>(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,update)=>AlertDialog(title:Text('مراجعة الانحراف • ${alert['site']}'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.n,style:TextStyle(fontWeight:FontWeight.bold)),SizedBox(height:8),Text(alert['noRecipe']==true?'صرف بلا وصفة: ${qtyText(alert['actual'] as double)} ${item.unit}':'زيادة ${qtyText(alert['difference'] as double)} ${item.unit} • ${(alert['percent'] as double).toStringAsFixed(1)}%'),Text('التكلفة التقديرية: ${cash(alert['cost'] as double)}'),if((alert['repeatCount']??1)>1)Text('تكرر خلال آخر 3 شهور: ${alert['repeatCount']} مرات',style:TextStyle(color:Colors.deepOrange,fontWeight:FontWeight.w600)),SizedBox(height:12),CheckboxListTile(contentPadding:EdgeInsets.zero,value:reviewed,title:Text(translateEnglish('تمت مراجعة التنبيه')),onChanged:(v)=>update(()=>reviewed=v??false)),TextField(controller:note,maxLines:3,decoration:InputDecoration(labelText:'سبب الانحراف / الإجراء التصحيحي',hintText:'اكتب الملاحظة هنا'))])),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()async{wasteAlertReviews[key]={'reviewed':reviewed,'note':note.text.trim(),'user':activeUser,'updatedAt':DateTime.now().toIso8601String()};final prefs=await SharedPreferences.getInstance();await prefs.setString('wasteAlertReviews',jsonEncode(wasteAlertReviews));addAudit(reviewed?'مراجعة تنبيه':'تحديث ملاحظة','انحراف مخزون','${alert['site']} • ${item.n} • ${note.text.trim()}');await save();if(mounted)setState((){});if(dc.mounted)Navigator.pop(dc);},child:Text(translateEnglish('حفظ المراجعة')))])));
}
int wasteOccurrenceCount(String site,Item item,DateTime from,DateTime to){final expected=expectedSiteConsumption(site,from,to)[item]??0.0;final actual=actualSiteIssues(site,from,to)[item]??0.0;if(expected>0){final diff=actual-expected;return diff>0&&diff/expected*100>=wasteAlertThreshold?1:0;}return expected<=0&&actual>0?1:0;}
void showRankedWasteDialog(List<Map<String,dynamic>> alerts) {
  showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
    title:Text(translateEnglish('ترتيب الهالك والانحراف — الشهر الحالي')),
    content:SizedBox(width:420,height:440,child:alerts.isEmpty
      ?Center(child:Text(translateEnglish('لا توجد تنبيهات خلال الشهر الحالي')))
      :ListView.builder(itemCount:alerts.length,itemBuilder:(ctx,index){
        final a=alerts[index];final item=a['item'] as Item;final noRecipe=a['noRecipe']==true;
        return ListTile(
          dense:true,
          leading:CircleAvatar(radius:15,child:Text('${index+1}',style:const TextStyle(fontSize:12))),
          title:Text('${a['site']} • ${item.n}'),
          subtitle:Text(noRecipe?'صرف بلا وصفة • ${qtyText(a['actual'] as double)} ${item.unit}':'زيادة ${(a['percent'] as double).toStringAsFixed(1)}% • ${qtyText(a['difference'] as double)} ${item.unit}'),
          trailing:Column(mainAxisSize:MainAxisSize.min,children:[Text(cash(a['cost'] as double),style:const TextStyle(fontWeight:FontWeight.bold,color:Colors.deepOrange)),Icon(wasteReviewFor(a,DateTime.now()).isNotEmpty&&wasteReviewFor(a,DateTime.now())['reviewed']==true?Icons.task_alt:Icons.rate_review_outlined,size:18,color:Colors.teal)]),onTap:()=>reviewWasteAlert(a,DateTime.now()),
        );
      })),
    actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(translateEnglish('إغلاق')))],
  ));
}
Widget dashboard() {
  final todayDays = days.where((x) => today(x.date) && (current.admin || current.sites.contains(x.site))).toList();
  final todayRevenue = todayDays.fold(0.0, (a, x) => a + rev(x));
  final todayMeals = todayDays.fold(0, (a, x) => a + x.b + x.l + x.d + x.e);
  final now=DateTime.now();
  final monthStart=DateTime(now.year,now.month,1);
  final wasteAlerts=buildWasteAlerts(monthStart,DateTime(now.year,now.month,now.day),wasteAlertThreshold);
  final overuseAlerts=wasteAlerts.where((x)=>x['noRecipe']!=true).toList();
  final noRecipeAlerts=wasteAlerts.where((x)=>x['noRecipe']==true).toList();
  final alertCost=overuseAlerts.fold<double>(0,(s,x)=>s+(x['cost'] as double));
  return ListView(
    padding: const EdgeInsets.all(14),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xff07594d), Color(0xff0b8874)], begin: Alignment.topRight, end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languageText('لوحة التحكم', 'Dashboard'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            SizedBox(height: 8),
            Text(languageText('إدارة مواقع التغذية\nبكل سهولة', 'Catering site management\nmade easy'), style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(languageText('الوجبات • المخزون • الإيرادات • متابعة المواقع', 'Meals • Inventory • Revenue • Site tracking'), style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text('ملخص اليوم', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff153b3a))),
      metric('إيراد اليوم', cash(todayRevenue), Icons.payments),
      metric('وجبات اليوم', todayMeals.toString(), Icons.restaurant),
      const SizedBox(height: 4),
      const Text('نظرة عامة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff153b3a))),
      metric('عدد المواقع', visibleSites.length.toString(), Icons.apartment),
      metric('عدد الخامات', visibleItems.length.toString(), Icons.inventory_2),
      metric('خامات وصلت حد التنبيه', visibleLowStockCount.toString(), Icons.warning_amber_rounded),
      metric('قيمة المخزون', cash(visibleStock), Icons.warehouse),
      Card(
        color: wasteAlerts.isEmpty ? const Color(0xffeaf7ef) : const Color(0xfffff3e5),
        child: ExpansionTile(
          leading: Icon(wasteAlerts.isEmpty?Icons.check_circle:Icons.warning_amber_rounded,color:wasteAlerts.isEmpty?Colors.green:Colors.deepOrange),
          title: Text(wasteAlerts.isEmpty?'متابعة الهالك والانحراف':'تنبيهات الهالك والانحراف (${wasteAlerts.length})',style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle: Text(wasteAlerts.isEmpty?'لا توجد تجاوزات بنسبة ${wasteAlertThreshold.toStringAsFixed(0)}% أو صرف خامات بلا وصفة هذا الشهر':'هالك زائد مرصود: ${cash(alertCost)} • ${wasteAlerts.where((a)=>wasteReviewFor(a,DateTime.now())['reviewed']!=true).length} تنبيه لم يُراجع • الشهر الحالي'),
          children: [
            ListTile(leading:Icon(Icons.tune),title:Text(translateEnglish('تغيير نسبة التنبيه الحالية: ${wasteAlertThreshold.toStringAsFixed(0)}%')),subtitle:Text(translateEnglish('اختيار الحد الذي يبدأ عنده التنبيه')),trailing:Icon(Icons.chevron_left),onTap:showWasteThresholdDialog),
            ListTile(leading:Icon(Icons.leaderboard),title:Text(translateEnglish('عرض ترتيب جميع الانحرافات')),subtitle:Text(translateEnglish('من الأعلى تكلفة إلى الأقل — الشهر الحالي')),onTap:()=>showRankedWasteDialog(wasteAlerts)),
            if(wasteAlerts.isEmpty) ListTile(dense:true,title:Text(translateEnglish('ممتاز! لا توجد تنبيهات حسب حد ${wasteAlertThreshold.toStringAsFixed(0)}% الحالي.'))),
            ...wasteAlerts.take(8).map((a){
              final item=a['item'] as Item;
              final missing=a['noRecipe']==true;
              return ListTile(
                dense:true,
                leading:Icon(missing?Icons.help_outline:Icons.trending_up,color:Colors.deepOrange),
                title:Text('${a['site']} • ${item.n}'),
                subtitle:Text((missing?'صرف ${qtyText(a['actual'] as double)} ${item.unit} بدون وصفة مسجلة':'زيادة ${qtyText(a['difference'] as double)} ${item.unit} • انحراف ${(a['percent'] as double).toStringAsFixed(1)}%')+((a['repeatCount']??1)>1?' • متكرر ${a['repeatCount']} مرات':'')),
                trailing:Column(mainAxisSize:MainAxisSize.min,children:[Text(cash(a['cost'] as double),style:const TextStyle(fontWeight:FontWeight.bold,color:Colors.deepOrange)),Icon(wasteReviewFor(a,DateTime.now()).isNotEmpty&&wasteReviewFor(a,DateTime.now())['reviewed']==true?Icons.task_alt:Icons.rate_review_outlined,size:18,color:Colors.teal)]),onTap:()=>reviewWasteAlert(a,DateTime.now()),
              );
            }),
            if(wasteAlerts.length>8) ListTile(title:Text(translateEnglish('يوجد ${wasteAlerts.length-8} تنبيه إضافي في تقرير الانحراف'))),
            if(can('التقارير')) ListTile(leading:Icon(Icons.analytics),title:Text(translateEnglish('فتح تقرير تحليل الانحراف')),onTap:(){setState(()=>tab=4);}),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text('إجراءات سريعة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff153b3a))),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (can('المواقع')) FilledButton.icon(onPressed: () => siteDialog(), icon: Icon(Icons.add_business), label: Text(translateEnglish('إضافة موقع'))),
          if (can('الوجبات')) FilledButton.icon(onPressed: () => dayDialog(), icon: Icon(Icons.restaurant), label: Text(translateEnglish('تسجيل وجبات'))),
          if (can('المخزون') && (current.admin || visibleWarehouses.any((w) => w.main))) FilledButton.icon(onPressed: () => itemDialog(), icon: Icon(Icons.add_box), label: Text(translateEnglish('إضافة خامة'))),
          if (current.admin) OutlinedButton.icon(onPressed: exportBackup, icon: Icon(Icons.backup), label: Text(translateEnglish('نسخة احتياطية'))),
          if (current.admin) OutlinedButton.icon(onPressed: restoreBackup, icon: Icon(Icons.restore), label: Text(translateEnglish('استعادة نسخة'))),
        ],
      ),
    ],
  );
}

Widget warehousePage() => ListView(padding:const EdgeInsets.all(12),children:[
Row(children:[Expanded(child:Text('إدارة المخازن',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:warehouseDialog,icon:Icon(Icons.add),label:Text(translateEnglish('مخزن جديد')))]),
Wrap(spacing:6,children:[FilledButton.icon(onPressed:transferDialog,icon:Icon(Icons.swap_horiz),label:Text(translateEnglish('تحويل مخزني'))),OutlinedButton.icon(onPressed:stockCountDialog,icon:Icon(Icons.fact_check),label:Text(translateEnglish('جرد وتسوية'))),OutlinedButton.icon(onPressed:movementHistoryDialog,icon:Icon(Icons.history),label:Text(translateEnglish('سجل الحركات')))]),
Card(child:ListTile(leading:Icon(Icons.info_outline),title:Text(translateEnglish('رصيد مستقل لكل مخزن')),subtitle:Text(translateEnglish('الاستلام والصرف والتحويلات تُسجل على المخزن المحدد.')))),
  ...visibleWarehouses.map((w)=>Card(child:ListTile(leading:Icon(w.main?Icons.warehouse:Icons.store,color:Colors.teal),title:Text(w.name),subtitle:Text((w.main?'مخزن رئيسي':'مخزن فرعي')+' • '+w.site+'\nقيمة الرصيد: '+cash(items.fold(0.0,(sum,it)=>sum+balance(it,w.name)*it.cost))),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>warehouseDialog(existing:w)))))
]);
Widget sitePage()=>ListView(padding:const EdgeInsets.all(12),children:[
Row(children:[Expanded(child:Text('المواقع والعقود',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:()=>siteDialog(),icon:Icon(Icons.add),label:Text(translateEnglish('إضافة موقع')))]),
if(visibleSites.isEmpty)Card(child:Padding(padding:EdgeInsets.all(20),child:Text(translateEnglish('لا توجد بيانات بعد')))),
...visibleSites.map((s)=>Card(child:ListTile(title:Text(s.name),subtitle:Text(s.client+'\nإفطار '+cash(s.b)+' / غداء '+cash(s.l)+' / عشاء '+cash(s.d)),trailing:IconButton(tooltip:'تعديل الموقع والعقد',icon:const Icon(Icons.edit),onPressed:()=>siteDialog(existing:s))))),
]);
Widget dayPage()=>listPage('سجل الوجبات',visibleDays.reversed.map((x)=>Card(child:ListTile(title:Text(x.site),subtitle:Text(x.date.day.toString()+'/'+x.date.month.toString()+' | إفطار '+x.b.toString()+' غداء '+x.l.toString()+' عشاء '+x.d.toString()+' إضافي '+x.e.toString()),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(cash(rev(x))),IconButton(tooltip:'تعديل',icon:const Icon(Icons.edit),onPressed:()=>dayDialog(existing:x)),IconButton(tooltip:'حذف',icon:const Icon(Icons.delete_outline,color:Colors.red),onPressed:()=>deleteDay(x))])))).toList(),dayDialog,'تسجيل وجبات');
Widget itemPage() => ListView(
  padding: const EdgeInsets.all(12),
  children: [
    Row(children: [
      const Expanded(child: Text('المخزون والخامات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      if (current.admin || visibleWarehouses.any((w) => w.main))
        FilledButton(onPressed: itemDialog, child: Text(translateEnglish('إضافة خامة'))),
    ]),
    if (visibleWarehouses.isNotEmpty)
      Wrap(spacing: 8, children: [
        OutlinedButton.icon(onPressed: () => movementDialog('صرف للموقع'), icon: Icon(Icons.output), label: Text(translateEnglish('صرف للاستهلاك بالموقع'))),
        OutlinedButton.icon(onPressed: importExcel, icon: Icon(Icons.upload_file), label: Text(translateEnglish('استيراد بيانات المخزون'))), 
        OutlinedButton.icon(onPressed: exportImportTemplate, icon: Icon(Icons.download), label: Text(translateEnglish('تحميل قالب الاستيراد'))),
        OutlinedButton.icon(onPressed: () => movementDialog('استلام'), icon: Icon(Icons.add_box), label: Text(translateEnglish('استلام خامات'))),
        OutlinedButton.icon(onPressed: () => movementDialog('صرف'), icon: Icon(Icons.remove_circle), label: Text(translateEnglish('صرف خامات'))),
        OutlinedButton.icon(onPressed: recipeDialog, icon: Icon(Icons.menu_book), label: Text(translateEnglish('وصفات الوجبات'))),
      ]),
    Card(child:ListTile(leading:Icon(Icons.info_outline,color:Colors.teal),title:Text(translateEnglish('تكلفة الموقع من الصرف الفعلي')),subtitle:Text(translateEnglish('التحويل بين المخازن لا يُحسب تكلفة. صرف الخامات للاستهلاك من مخزن الموقع يُضاف تلقائيًا لتكلفة الموقع، مع حفظ تكلفة الوحدة وقت الصرف.')))),
    if (visibleItems.isEmpty)
      Card(child: Padding(padding: EdgeInsets.all(18), child: Text(translateEnglish('لا توجد خامات أو لا توجد مخازن مسموح بها')))),
    ...visibleItems.map((x) => Card(
      child: ListTile(
        title: Text(x.n),
        subtitle: Text(x.code + ' | ' + x.unit + ' | حد التنبيه ' + qtyText(x.min) + '\n' + visibleWarehouses.map((w) => w.name + ': ' + qtyText(balance(x, w.name))).join(' | ')),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(qtyText(visibleWarehouses.fold(0.0, (sum, w) => sum + balance(x, w.name))) + ' ' + x.unit),
            Text(cash(visibleWarehouses.fold(0.0, (sum, w) => sum + balance(x, w.name)) * x.cost), style: const TextStyle(fontSize: 11)),
          ]),
          IconButton(tooltip: translateEnglish('تعديل الخامة'), icon: Icon(Icons.edit), onPressed: () => itemDialog(existing: x)),
          IconButton(tooltip: translateEnglish('حذف الخامة'), icon: Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteItem(x)),
        ]),
      ),
    )),
    const Padding(padding: EdgeInsets.only(top: 12), child: Text('آخر حركات المخزون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    if (visibleMovements.isEmpty) Text(translateEnglish('لا توجد حركات مسجلة')),
    ...visibleMovements.reversed.take(30).map((m) => Card(
      child: ListTile(
        leading: Icon(m.type == 'استلام' ? Icons.arrow_downward : Icons.arrow_upward, color: m.type == 'استلام' ? Colors.green : Colors.orange),
        title: Text(m.item + ' — ' + m.type + ' ' + qtyText(m.qty)),
        subtitle: Text(m.date.day.toString() + '/' + m.date.month.toString() + '/' + m.date.year.toString() + (m.note.isEmpty ? '' : '\n' + m.note)),
      ),
    )),
  ],
);
double mealCost(Day x){double total=0;for(final r in recipes){final count=r.meal=='إفطار'?x.b:r.meal=='غداء'?x.l:r.meal=='عشاء'?x.d:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)total+=count*r.qty*found.first.cost;}return total;}
String reportDateText(DateTime date)=>'${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
Future<void> pickReportDate(bool start)async{
  final picked=await showDatePicker(context:context,initialDate:start?reportFrom:reportTo,firstDate:DateTime(2020),lastDate:DateTime(2100),helpText:start?'اختر بداية التقرير':'اختر نهاية التقرير');
  if(picked==null)return;
  setState((){
    if(start){reportFrom=DateTime(picked.year,picked.month,picked.day);if(reportFrom.isAfter(reportTo))reportTo=reportFrom;}
    else{reportTo=DateTime(picked.year,picked.month,picked.day);if(reportTo.isBefore(reportFrom))reportFrom=reportTo;}
  });
}
Future<void> exportReportExcel(List<Day> periodDays,DateTime from,DateTime to)async{
 try{
  final book=Excel.createExcel();
  book.rename('Sheet1','ملخص التقرير');
  final summary=book['ملخص التقرير'];
  summary.appendRow([TextCellValue('تقرير StockPro'),TextCellValue('من'),TextCellValue(reportDateText(from)),TextCellValue('إلى'),TextCellValue(reportDateText(to))]);
  summary.appendRow([TextCellValue('المؤشر'),TextCellValue('القيمة')]);
  int breakfast=0,lunch=0,dinner=0,extra=0;double revenue=0,rawCost=0;final periodExpenses=expenses.where((x){final date=DateTime(x.date.year,x.date.month,x.date.day);return !date.isBefore(DateTime(from.year,from.month,from.day))&&!date.isAfter(DateTime(to.year,to.month,to.day))&&(current.admin||current.sites.contains(x.site));}).toList();final expensesTotal=periodExpenses.fold<double>(0.0,(double sum,Expense x)=>sum+x.amount);
  for(final entry in periodDays){breakfast+=entry.b;lunch+=entry.l;dinner+=entry.d;extra+=entry.e;revenue+=rev(entry);}rawCost=visibleSites.fold<double>(0,(sum,site)=>sum+siteMaterialCost(site.name,from,to));
  summary.appendRow([TextCellValue('إفطار'),IntCellValue(breakfast)]);
  summary.appendRow([TextCellValue('غداء'),IntCellValue(lunch)]);
  summary.appendRow([TextCellValue('عشاء'),IntCellValue(dinner)]);
  summary.appendRow([TextCellValue('وجبات إضافية'),IntCellValue(extra)]);
  summary.appendRow([TextCellValue('إجمالي الوجبات'),IntCellValue(breakfast+lunch+dinner+extra)]);
  summary.appendRow([TextCellValue('إيراد الوجبات المسعّرة'),DoubleCellValue(revenue)]);
  summary.appendRow([TextCellValue('تكلفة الخامات المصروفة فعليًا للمواقع'),DoubleCellValue(rawCost)]);
  summary.appendRow([TextCellValue('الفائض بعد تكلفة الخامات'),DoubleCellValue(revenue-rawCost)]);summary.appendRow([TextCellValue('مصروفات المواقع'),DoubleCellValue(expensesTotal)]);summary.appendRow([TextCellValue('صافي الربح بعد المصروفات'),DoubleCellValue(revenue-rawCost-expensesTotal)]);final expenseSheet=book['المصروفات'];expenseSheet.appendRow([TextCellValue('التاريخ'),TextCellValue('الموقع'),TextCellValue('التصنيف'),TextCellValue('المبلغ'),TextCellValue('ملاحظات')]);for(final x in periodExpenses){expenseSheet.appendRow([TextCellValue(reportDateText(x.date)),TextCellValue(x.site),TextCellValue(x.category),DoubleCellValue(x.amount),TextCellValue(x.note)]);}
  final bySite=book['تفصيل المواقع'];
  bySite.appendRow([TextCellValue('الموقع'),TextCellValue('إفطار'),TextCellValue('غداء'),TextCellValue('عشاء'),TextCellValue('إضافية'),TextCellValue('الإجمالي'),TextCellValue('الإيراد'),TextCellValue('تكلفة الخامات'),TextCellValue('الفائض'),TextCellValue('مصروفات'),TextCellValue('صافي الربح')]);
  for(final site in visibleSites){
   int b=0,l=0,d=0,e=0;double amount=0,cost=0;
   for(final entry in periodDays){if(entry.site==site.name){b+=entry.b;l+=entry.l;d+=entry.d;e+=entry.e;amount+=rev(entry);}}cost=siteMaterialCost(site.name,from,to);
   final siteExpenses=periodExpenses.where((x)=>x.site==site.name).fold<double>(0.0,(double sum,Expense x)=>sum+x.amount);bySite.appendRow([TextCellValue(site.name),IntCellValue(b),IntCellValue(l),IntCellValue(d),IntCellValue(e),IntCellValue(b+l+d+e),DoubleCellValue(amount),DoubleCellValue(cost),DoubleCellValue(amount-cost),DoubleCellValue(siteExpenses),DoubleCellValue(amount-cost-siteExpenses)]);
  }
  final daily=book['تفصيل التسجيلات'];
  daily.appendRow([TextCellValue('التاريخ'),TextCellValue('الموقع'),TextCellValue('إفطار'),TextCellValue('غداء'),TextCellValue('عشاء'),TextCellValue('إضافية'),TextCellValue('الإجمالي'),TextCellValue('الإيراد'),TextCellValue('تكلفة الخامات'),TextCellValue('الفائض')]);
  final ordered=List<Day>.from(periodDays)..sort((a,b)=>a.date.compareTo(b.date));
  for(final entry in ordered){final amount=rev(entry),cost=linkedDayMaterialCost(entry.id);daily.appendRow([TextCellValue(reportDateText(entry.date)),TextCellValue(entry.site),IntCellValue(entry.b),IntCellValue(entry.l),IntCellValue(entry.d),IntCellValue(entry.e),IntCellValue(entry.b+entry.l+entry.d+entry.e),DoubleCellValue(amount),DoubleCellValue(cost),DoubleCellValue(amount-cost)]);}
  final siteIssues=book['صرف الخامات للمواقع'];siteIssues.appendRow([TextCellValue('التاريخ'),TextCellValue('الموقع'),TextCellValue('المخزن'),TextCellValue('الصنف'),TextCellValue('الكمية'),TextCellValue('تكلفة الوحدة'),TextCellValue('إجمالي التكلفة'),TextCellValue('نوع الحركة'),TextCellValue('ملاحظات')]);for(final m in movements.where((m)=>isSiteConsumption(m)&&visibleSites.any((s)=>s.name==movementSite(m))&&DateTime(m.date.year,m.date.month,m.date.day).compareTo(DateTime(from.year,from.month,from.day))>=0&&DateTime(m.date.year,m.date.month,m.date.day).compareTo(DateTime(to.year,to.month,to.day))<=0)){final it=items.firstWhere((i)=>i.n==m.item,orElse:()=>Item(m.item,'','',0,0,0));siteIssues.appendRow([TextCellValue(reportDateText(m.date)),TextCellValue(movementSite(m)??''),TextCellValue(m.warehouse),TextCellValue(m.item),DoubleCellValue(m.qty),DoubleCellValue(m.unitCost??it.cost),DoubleCellValue(movementCost(m)),TextCellValue(m.type),TextCellValue(m.note)]);}
  final varianceSheet=book['تحليل الانحراف والهالك'];varianceSheet.appendRow([TextCellValue('الموقع'),TextCellValue('الصنف'),TextCellValue('الوحدة'),TextCellValue('الاستهلاك النظري'),TextCellValue('الصرف الفعلي اليدوي'),TextCellValue('الزيادة / العجز'),TextCellValue('نسبة الانحراف %'),TextCellValue('تكلفة الانحراف')]);for(final site in visibleSites){final expected=expectedSiteConsumption(site.name,from,to),actual=actualSiteIssues(site.name,from,to);final allItems={...expected.keys,...actual.keys};for(final item in allItems){final e=expected[item]??0.0,a=actual[item]??0.0,d=a-e;final pct=e>0?d/e*100:null;varianceSheet.appendRow([TextCellValue(site.name),TextCellValue(item.n),TextCellValue(item.unit),DoubleCellValue(e),DoubleCellValue(a),DoubleCellValue(d),pct==null?TextCellValue('لا توجد وصفة'):DoubleCellValue(pct),DoubleCellValue(d*item.cost)]);}}
   final encoded=book.encode();
  if(encoded==null)throw Exception('تعذر إنشاء ملف Excel');
  final fileName='StockPro_Report_${from.year}${from.month.toString().padLeft(2,'0')}${from.day.toString().padLeft(2,'0')}_to_${to.year}${to.month.toString().padLeft(2,'0')}${to.day.toString().padLeft(2,'0')}.xlsx';
  final saved=await FilePicker.platform.saveFile(fileName:fileName,bytes:Uint8List.fromList(encoded),type:FileType.custom,allowedExtensions:['xlsx']);
  if(!mounted)return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(saved==null?'تم إلغاء حفظ التقرير':'تم تصدير التقرير بنجاح')));
 }catch(e){
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('فشل تصدير التقرير: $e'))));
 }
}
Widget reportPage(){
  final periodExpenses=expenses.where((x){final date=DateTime(x.date.year,x.date.month,x.date.day);return !date.isBefore(DateTime(reportFrom.year,reportFrom.month,reportFrom.day))&&!date.isAfter(DateTime(reportTo.year,reportTo.month,reportTo.day))&&(current.admin||current.sites.contains(x.site));}).toList();
  final expensesTotal=periodExpenses.fold<double>(0.0,(double sum,Expense x)=>sum+x.amount);
  final now=DateTime.now();
  final from=DateTime(reportFrom.year,reportFrom.month,reportFrom.day);
  final to=DateTime(reportTo.year,reportTo.month,reportTo.day);
  final periodDays=days.where((x){
    final date=DateTime(x.date.year,x.date.month,x.date.day);
    return !date.isBefore(from)&&!date.isAfter(to)&&(current.admin||current.sites.contains(x.site));
  }).toList();
  int breakfast=0,lunch=0,dinner=0,extra=0;
  double revenue=0,rawCost=0;
  for(final entry in periodDays){
    breakfast+=entry.b;lunch+=entry.l;dinner+=entry.d;extra+=entry.e;
    revenue+=rev(entry);
  }
  rawCost=visibleSites.fold<double>(0,(sum,site)=>sum+siteMaterialCost(site.name,from,to));
  final allMeals=breakfast+lunch+dinner+extra;
  final siteCostRanking=visibleSites.map((site){final siteCost=siteMaterialCost(site.name,from,to);return MapEntry(site.name,siteCost);}).toList()..sort((a,b)=>b.value.compareTo(a.value));
  final varianceSites=visibleSites.map((site){final expected=expectedSiteConsumption(site.name,from,to),actual=actualSiteIssues(site.name,from,to);final allItems={...expected.keys,...actual.keys};final rows=allItems.map((item){final e=expected[item]??0.0,a=actual[item]??0.0,d=a-e;return {'item':item,'expected':e,'actual':a,'difference':d,'percent':e>0?d/e*100:null,'cost':d*item.cost};}).toList()..sort((a,b)=>(b['cost'] as double).compareTo(a['cost'] as double));final totalExpected=expected.values.fold<double>(0,(s,v)=>s+v),totalActual=actual.values.fold<double>(0,(s,v)=>s+v);final costVariance=rows.fold<double>(0,(s,r)=>s+(r['cost'] as double));return {'site':site.name,'rows':rows,'expected':totalExpected,'actual':totalActual,'cost':costVariance};}).toList();
  final averageMaterialCostPerMeal=allMeals>0?rawCost/allMeals:0.0;
  final rows=<Widget>[
    const Text('تقرير الوجبات والإيرادات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('حدد فترة التقرير',style:TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      Wrap(spacing:8,runSpacing:8,children:[
        OutlinedButton.icon(onPressed:()=>pickReportDate(true),icon:Icon(Icons.calendar_today),label:Text(translateEnglish('من: ${reportDateText(from)}'))),
        OutlinedButton.icon(onPressed:()=>pickReportDate(false),icon:Icon(Icons.event),label:Text(translateEnglish('إلى: ${reportDateText(to)}'))),
        TextButton(onPressed:()=>setState((){reportFrom=DateTime(now.year,now.month,1);reportTo=DateTime(now.year,now.month,now.day);}),child:Text(translateEnglish('الشهر الحالي'))),
        TextButton(onPressed:()=>setState((){reportTo=DateTime(now.year,now.month,now.day);reportFrom=DateTime(now.year,now.month,now.day).subtract(Duration(days:29));}),child:Text(translateEnglish('آخر 30 يوم'))),
      ]),
      Text('الفترة المختارة: ${reportDateText(from)} — ${reportDateText(to)}',style:const TextStyle(color:Colors.teal,fontWeight:FontWeight.w600)),
      const SizedBox(height:10),
      FilledButton.icon(onPressed:()=>exportReportExcel(periodDays,from,to),icon:Icon(Icons.file_download),label:Text(translateEnglish('تصدير التقرير إلى Excel')),),
    ]))),
    Card(child:Padding(padding:const EdgeInsets.all(14),child:Wrap(spacing:8,runSpacing:8,children:[
      Chip(label:Text(translateEnglish('إفطار: $breakfast'))),
      Chip(label:Text(translateEnglish('غداء: $lunch'))),
      Chip(label:Text(translateEnglish('عشاء: $dinner'))),
      Chip(label:Text(translateEnglish('إضافية: $extra'))),
    ]))),
    const Padding(padding:EdgeInsets.only(top:14,bottom:6),child:Text('مراقبة الاستهلاك والانحراف عن الوصفة',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),
    Card(child:Padding(padding:EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(translateEnglish('مقارنة الصرف اليدوي للمواقع بالاستهلاك النظري المحسوب من الوجبات والوصفات. حركات استهلاك الوجبات التلقائية لا تدخل في الصرف الفعلي هنا لتجنب احتسابها مرتين.')),SizedBox(height:8),Text('تكلفة الانحراف الصافية: '+cash(varianceSites.fold<double>(0,(sum,s)=>sum+(s['cost'] as double))),style:TextStyle(fontWeight:FontWeight.bold))]))),
    ...varianceSites.map((s) {
      final rows = s['rows'] as List<Map<String, dynamic>>;
      return Card(
        child: ExpansionTile(
          leading: const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
          title: Text(s['site'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('نظري ${qtyText(s['expected'] as double)} • فعلي ${qtyText(s['actual'] as double)} • تكلفة الانحراف ${cash(s['cost'] as double)}'),
          children: rows.isEmpty
              ? [ListTile(title: Text(translateEnglish('لا توجد وصفات أو صرف يدوي للمقارنة')))]
              : rows.map((r) {
                  final item = r['item'] as Item;
                  final e = r['expected'] as double;
                  final a = r['actual'] as double;
                  final d = r['difference'] as double;
                  final p = r['percent'] as double?;
                  final cost = r['cost'] as double;
                  return ListTile(
                    dense: true,
                    title: Text(item.n),
                    subtitle: Text('نظري ${qtyText(e)} ${item.unit} | فعلي ${qtyText(a)} | انحراف ${p == null ? 'غير محسوب (لا توجد وصفة)' : '${p.toStringAsFixed(1)}%'}'),
                    trailing: Text('${d >= 0 ? '+' : ''}${qtyText(d)}\\n${cash(cost)}', textAlign: TextAlign.end, style: TextStyle(color: d > 0 ? Colors.red : d < 0 ? Colors.green : null, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
        ),
      );
    }),
    metric('إجمالي الوجبات',allMeals.toString(),Icons.restaurant),
    metric('إيراد الوجبات المسعّرة',cash(revenue),Icons.payments),
    metric('تكلفة الخامات المصروفة فعليًا',cash(rawCost),Icons.calculate),
    metric('متوسط تكلفة الخامات لكل وجبة',cash(averageMaterialCostPerMeal),Icons.analytics),
    if(siteCostRanking.isNotEmpty) Card(child:ListTile(leading:Icon(Icons.leaderboard,color:Colors.deepOrange),title:Text(translateEnglish('أعلى موقع في تكلفة الخامات')),subtitle:Text(siteCostRanking.first.key),trailing:Text(cash(siteCostRanking.first.value),style:TextStyle(fontWeight:FontWeight.bold)))),
    metric('الفائض بعد تكلفة الخامات',cash(revenue-rawCost),Icons.trending_up),metric('مصروفات المواقع خلال الفترة',cash(expensesTotal),Icons.receipt_long),metric('صافي الربح بعد المصروفات',cash(revenue-rawCost-expensesTotal),Icons.account_balance),
    Card(child:ListTile(leading:Icon(Icons.info_outline),title:Text(translateEnglish('ملاحظة محاسبية')),subtitle:Text(translateEnglish('الوجبات الإضافية: $extra وجبة. لا تدخل في الإيراد أو تكلفة الوصفات حاليًا لعدم وجود سعر تعاقدي ووصفة محددة لها. الفائض المعروض لا يشمل العمالة أو النقل أو المصروفات التشغيلية.')))),
    const Padding(padding:EdgeInsets.only(top:12,bottom:6),child:Text('تفصيل الأداء حسب الموقع',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),
  ];
  for(final site in visibleSites){
    int b=0,l=0,d=0,e=0;double amount=0,cost=0;
    for(final entry in periodDays){
      if(entry.site==site.name){
        b+=entry.b;l+=entry.l;d+=entry.d;e+=entry.e;
        amount+=rev(entry);
      }
    }
    cost=siteMaterialCost(site.name,from,to);final count=b+l+d+e;final itemCosts=<String,double>{};for(final movement in siteCostMovements(site.name,from,to)){itemCosts[movement.item]=(itemCosts[movement.item]??0)+movementCost(movement);}final sortedItemCosts=itemCosts.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    rows.add(Card(child:ExpansionTile(
      leading:const Icon(Icons.apartment,color:Colors.teal),
      title:Text(site.name,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Text(translateEnglish('$count وجبة • إيراد ${cash(amount)}')),
      children:[
        ListTile(dense:true,title:Text(translateEnglish('إفطار')),trailing:Text(translateEnglish('$b وجبة × ${cash(site.b)} = ${cash(b*site.b)}'))),
        ListTile(dense:true,title:Text(translateEnglish('غداء')),trailing:Text(translateEnglish('$l وجبة × ${cash(site.l)} = ${cash(l*site.l)}'))),
        ListTile(dense:true,title:Text(translateEnglish('عشاء')),trailing:Text(translateEnglish('$d وجبة × ${cash(site.d)} = ${cash(d*site.d)}'))),
        ListTile(dense:true,title:Text(translateEnglish('وجبات إضافية')),trailing:Text(translateEnglish('$e وجبة • غير مسعّرة'))),
        const Divider(),
        ListTile(dense:true,title:Text(translateEnglish('تكلفة الخامات المصروفة فعليًا')),trailing:Text(cash(cost))),
        if(sortedItemCosts.isNotEmpty)const ListTile(dense:true,title:Text('تفصيل التكلفة حسب الخامة',style:TextStyle(fontWeight:FontWeight.bold))),
        ...sortedItemCosts.map((entry)=>ListTile(dense:true,leading:Icon(Icons.inventory_2_outlined),title:Text(entry.key),subtitle:Text(translateEnglish('إجمالي تكلفة الصنف خلال الفترة')),trailing:Text(cash(entry.value)))),
        const Divider(),
        ...siteCostMovements(site.name,from,to).map((m)=>ListTile(dense:true,leading:const Icon(Icons.receipt_long_outlined),title:Text(m.item+' • '+qtyText(m.qty)),subtitle:Text(m.date.toString()+' | '+m.warehouse+' | '+m.type),trailing:Text(cash(movementCost(m))))),
        ListTile(dense:true,title:Text(translateEnglish('الفائض بعد تكلفة الخامات')),trailing:Text(cash(amount-cost),style:TextStyle(fontWeight:FontWeight.bold,color:Colors.teal))),
      ],
    )));
  }
  if(periodDays.isEmpty)rows.add(Card(child:Padding(padding:EdgeInsets.all(16),child:Text(translateEnglish('لا توجد وجبات مسجلة خلال الفترة المختارة للمواقع المسموح بها.')))));
  return ListView(padding:const EdgeInsets.all(14),children:rows);
}
Widget listPage(String title,List<Widget> rows,VoidCallback add,String label)=>ListView(padding:EdgeInsets.all(12),children:[Row(children:[Expanded(child:Text(title,style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton(onPressed:add,child:Text(label))]),if(rows.isEmpty)Card(child:Padding(padding:EdgeInsets.all(20),child:Text(translateEnglish('لا توجد بيانات بعد')))),...rows]);
Future<void> warehouseDialog({Warehouse? existing}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final manager = TextEditingController(text: existing?.manager ?? '');
  final siteOptions = ['كل الشركة', ...sites.map((s) => s.name)];
  String selectedSite = siteOptions.contains(existing?.site) ? existing!.site : 'كل الشركة';
  bool isMain = existing?.main ?? false;
  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(existing == null ? 'إضافة مخزن' : 'تعديل المخزن'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            field(name, translateEnglish('اسم المخزن')),
            DropdownButtonFormField<String>(
              value: selectedSite,
              decoration: InputDecoration(labelText: translateEnglish('الموقع / نطاق المخزن')),
              items: siteOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) { if (v != null) setDialogState(() => selectedSite = v); },
            ),
            field(manager, translateEnglish('المسؤول')),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(translateEnglish('مخزن رئيسي')),
              value: isMain,
              onChanged: (v) => setDialogState(() => isMain = v ?? false),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(translateEnglish('إلغاء'))),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('اكتب اسم المخزن'))));
                return;
              }
              if (isMain && warehouses.any((w) => w.main && w != existing)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('يوجد مخزن رئيسي بالفعل'))));
                return;
              }
              final updated = Warehouse(name.text.trim(), selectedSite, manager.text.trim(), isMain);
              if (existing == null) {
                warehouses.add(updated);
              } else {
                if(existing.name!=updated.name){final oldName=existing.name;final oldBalances=stockBalances.remove(oldName);if(oldBalances!=null)stockBalances[updated.name]=oldBalances;for(final u in users){if(u.warehouses.remove(oldName))u.warehouses.add(updated.name);}for(final m in movements){if(m.warehouse==oldName)m.warehouse=updated.name;}}
                existing.name = updated.name;
                existing.site = updated.site;
                existing.manager = updated.manager;
                existing.main = updated.main;
              }
              addAudit(existing==null?'إضافة':'تعديل','مخزن',updated.name+' • '+updated.site);save();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: Text(translateEnglish('حفظ')),
          ),
        ],
      ),
    ),
  );
}
Future<void> siteDialog({Site? existing})async{final n=TextEditingController(text:existing?.name??''),c=TextEditingController(text:existing?.client??''),b=TextEditingController(text:(existing?.b??0).toString()),l=TextEditingController(text:(existing?.l??0).toString()),d=TextEditingController(text:(existing?.d??0).toString());await showDialog(context:context,builder:(x)=>AlertDialog(title:Text(existing==null?'إضافة موقع / عقد':'تعديل الموقع / العقد'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n, translateEnglish('اسم الموقع')),field(c, translateEnglish('العميل')),field(b, translateEnglish('سعر الإفطار'),numeric:true),field(l, translateEnglish('سعر الغداء'),numeric:true),field(d, translateEnglish('سعر العشاء'),numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:(){final name=n.text.trim();final vb=double.tryParse(b.text.trim().replaceAll(',','.')),vl=double.tryParse(l.text.trim().replaceAll(',','.')),vd=double.tryParse(d.text.trim().replaceAll(',','.'));if(name.isEmpty||vb==null||vl==null||vd==null||vb<0||vl<0||vd<0){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أدخل اسم الموقع وأسعارًا صحيحة غير سالبة'))));return;}if(sites.any((s)=>s.name==name&&s!=existing)){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('اسم الموقع موجود بالفعل'))));return;}if(existing==null){sites.add(Site(name,c.text.trim(),vb,vl,vd));addAudit('إضافة','موقع',name+' • '+c.text.trim());}else{final oldName=existing.name;if(oldName!=name){for(final day in days){if(day.site==oldName)day.site=name;}for(final wh in warehouses){if(wh.site==oldName)wh.site=name;}for(final expense in expenses){if(expense.site==oldName)expense.site=name;}for(final user in users){if(user.sites.remove(oldName))user.sites.add(name);}}existing.name=name;existing.client=c.text.trim();existing.b=vb;existing.l=vl;existing.d=vd;addAudit('تعديل','موقع / عقد',oldName+' ← '+name+' • أسعار الوجبات تم تحديثها');}save();setState((){});Navigator.pop(x);},child:Text(translateEnglish('حفظ')))]));}
Future<void> deleteDay(Day record)async{
  final linked=movements.where((m)=>m.ref.isNotEmpty&&m.ref==record.id).toList();
  if(record.id.isEmpty&&movements.any((m)=>m.type=='استهلاك وجبات')){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('لا يمكن حذف سجل قديم غير مرتبط بحركات الاستهلاك؛ حفاظاً على دقة أرصدة المخازن.'))));
    return;
  }
  final ok=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:Text(translateEnglish('حذف سجل الوجبات')),content:Text(translateEnglish('هل تريد حذف تسجيل وجبات موقع ${record.site}؟ سيتم إرجاع الخامات التي استهلكها هذا التسجيل إلى المخزن.')),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:Text(translateEnglish('حذف')))]));
  if(ok!=true)return;
  for(final m in linked){final item=items.where((i)=>i.n==m.item);if(item.isNotEmpty)setBalance(item.first,m.warehouse,balance(item.first,m.warehouse)+m.qty);}
  movements.removeWhere((m)=>m.ref.isNotEmpty&&m.ref==record.id);
  days.remove(record);addAudit('حذف','تسجيل وجبات',record.site+' • '+record.date.toLocal().toString());
  await save();
  if(mounted)setState((){});
}
Future<void> dayDialog({Day? existing})async{
  if(visibleSites.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('سجل موقع وعقد أولاً'))));return;}
  if(existing!=null&&existing.id.isEmpty&&movements.any((m)=>m.type=='استهلاك وجبات')){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('هذا سجل قديم غير مرتبط بحركات الاستهلاك؛ لا يمكن تعديله بأمان. السجلات الجديدة تدعم التعديل والحذف.'))));
    return;
  }
  Site chosen=visibleSites.firstWhere((s)=>s.name==existing?.site,orElse:()=>visibleSites.first);
  final b=TextEditingController(text:(existing?.b??0).toString()),l=TextEditingController(text:(existing?.l??0).toString()),d=TextEditingController(text:(existing?.d??0).toString()),e=TextEditingController(text:(existing?.e??0).toString());
  final linked=existing==null? <Movement>[]:movements.where((m)=>m.ref.isNotEmpty&&m.ref==existing.id).toList();
  await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:Text(existing==null?'تسجيل الوجبات اليومية':'تعديل تسجيل الوجبات'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    DropdownButtonFormField<Site>(value:chosen,items:visibleSites.map((site)=>DropdownMenuItem(value:site,child:Text(site.name))).toList(),onChanged:(v){if(v!=null)set(()=>chosen=v);}),
    field(b, translateEnglish('عدد الإفطار'),numeric:true,decimal:false),field(l, translateEnglish('عدد الغداء'),numeric:true,decimal:false),field(d, translateEnglish('عدد العشاء'),numeric:true,decimal:false),field(e, translateEnglish('وجبات إضافية غير مسعرة'),numeric:true,decimal:false),
    Text('أسعار العقد: '+cash(chosen.b)+' / '+cash(chosen.l)+' / '+cash(chosen.d))
  ])),actions:[
    TextButton(onPressed:()=>Navigator.pop(x),child:Text(translateEnglish('إلغاء'))),
    FilledButton(onPressed:(){
      final nb=int.tryParse(b.text)??-1,nl=int.tryParse(l.text)??-1,nd=int.tryParse(d.text)??-1,ne=int.tryParse(e.text)??-1;
      if([nb,nl,nd,ne].any((v)=>v<0)){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أدخل أعداداً صحيحة غير سالبة'))));return;}
      final need=<Item,double>{};
      for(final recipe in recipes){
        final count=recipe.meal=='إفطار'?nb:recipe.meal=='غداء'?nl:recipe.meal=='عشاء'?nd:0;
        final found=items.where((i)=>i.n==recipe.item);
        if(found.isNotEmpty)need[found.first]=(need[found.first]??0)+count*recipe.qty;
      }
      final consumeWh=existing!=null&&linked.isNotEmpty?warehouses.firstWhere((w)=>w.name==linked.first.warehouse,orElse:()=>mainWarehouse):(warehouses.where((w)=>!w.main&&w.site==chosen.name).firstOrNull??mainWarehouse);
      final restored=<Item,double>{};
      for(final movement in linked){final found=items.where((i)=>i.n==movement.item);if(found.isNotEmpty)restored[found.first]=(restored[found.first]??0)+movement.qty;}
      final shortage=need.entries.where((entry)=>entry.value>balance(entry.key,consumeWh.name)+(restored[entry.key]??0)).toList();
      if(shortage.isNotEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('رصيد غير كافٍ في '+consumeWh.name+': '+shortage.map((entry)=>entry.key.n+' (متاح '+qtyText(balance(entry.key,consumeWh.name)+(restored[entry.key]??0))+')').join('، '))));return;}
      for(final movement in linked){final found=items.where((i)=>i.n==movement.item);if(found.isNotEmpty)setBalance(found.first,movement.warehouse,balance(found.first,movement.warehouse)+movement.qty);}
      if(existing==null){
        final record=Day(chosen.name,DateTime.now(),nb,nl,nd,ne);
        days.add(record);
        for(final entry in need.entries){setBalance(entry.key,consumeWh.name,balance(entry.key,consumeWh.name)-entry.value);movements.add(Movement(entry.key.n,'استهلاك وجبات',entry.value,'موقع: '+chosen.name,DateTime.now(),consumeWh.name,record.id,entry.key.cost));}
      }else{
        movements.removeWhere((m)=>m.ref.isNotEmpty&&m.ref==existing.id);
        existing.site=chosen.name;existing.b=nb;existing.l=nl;existing.d=nd;existing.e=ne;
        for(final entry in need.entries){setBalance(entry.key,consumeWh.name,balance(entry.key,consumeWh.name)-entry.value);movements.add(Movement(entry.key.n,'استهلاك وجبات',entry.value,'موقع: '+chosen.name,DateTime.now(),consumeWh.name,existing.id,entry.key.cost));}
      }
      addAudit(existing==null?'إضافة':'تعديل','تسجيل وجبات',chosen.name+' • إفطار '+nb.toString()+' / غداء '+nl.toString()+' / عشاء '+nd.toString());save();setState((){});Navigator.pop(x);
    },child:Text(existing==null?'حفظ':'حفظ التعديلات'))
  ])));
}
Future<void> movementDialog(String type) async {
if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أضف خامة أولاً'))));return;}
Item selected=items.first;final movementWarehouses=type=='صرف للموقع'?visibleWarehouses.where((w)=>!w.main&&visibleSites.any((s)=>s.name==w.site)).toList():visibleWarehouses;if(movementWarehouses.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(type=='صرف للموقع'?'لا يوجد مخزن موقع مسموح بالصرف منه':'لا يوجد مخزن مسموح لك بالتعامل معه')));return;}Warehouse wh=movementWarehouses.first;final qty=TextEditingController(),note=TextEditingController();
await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,upd)=>AlertDialog(title:Text(translateEnglish('$type خامات')),content:Column(mainAxisSize:MainAxisSize.min,children:[
DropdownButtonFormField<Warehouse>(value:wh,items:movementWarehouses.map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null)upd(()=>wh=v);}),
DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)upd(()=>selected=v);}),
field(qty, translateEnglish('الكمية بوحدة ')+selected.unit,numeric:true),field(note, translateEnglish('ملاحظات')),Text('الرصيد الحالي: '+qtyText(balance(selected,wh.name))+' '+selected.unit)
]),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:(){
final amount=double.tryParse(qty.text.trim().replaceAll(',','.'));if(amount==null||amount<=0){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أدخل كمية صحيحة'))));return;}
final current=balance(selected,wh.name);if((type=='صرف'||type=='صرف للموقع')&&amount>current){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('رصيد غير كافٍ بالمخزن'))));return;}
setBalance(selected,wh.name,current+(type=='استلام'?amount:-amount));final movementNote=type=='صرف للموقع'?'موقع: '+wh.site+(note.text.trim().isEmpty?'':' • '+note.text.trim()):note.text.trim();movements.add(Movement(selected.n,type,amount,movementNote,DateTime.now(),wh.name,'',selected.cost));addAudit(type,'حركة مخزون',selected.n+' • '+qtyText(amount)+' '+selected.unit+' • '+wh.name+' • '+movementNote);save();setState(()=>{});Navigator.pop(dc);
},child:Text(translateEnglish('تأكيد')))])));
}
Future<void> transferDialog()async{
final available=visibleWarehouses;
if(available.length<2){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('لازم يكون عندك مخزنان على الأقل لإجراء التحويل'))));return;}
if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أضف خامة أولاً'))));return;}
Warehouse source=available.firstWhere((w)=>w.main,orElse:()=>available.first);
Warehouse target=available.firstWhere((w)=>w!=source);
Item selected=items.first;final q=TextEditingController(),note=TextEditingController();
await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,upd)=>AlertDialog(title:Text(translateEnglish('إذن تحويل مخزني')),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
DropdownButtonFormField<Warehouse>(value:source,decoration:const InputDecoration(labelText:'من المخزن'),items:available.map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null){upd(()=>source=v);if(target==source)upd(()=>target=available.firstWhere((w)=>w!=source));}}),
DropdownButtonFormField<Warehouse>(value:target,decoration:const InputDecoration(labelText:'إلى المخزن'),items:available.where((w)=>w!=source).map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null)upd(()=>target=v);}),
DropdownButtonFormField<Item>(value:selected,decoration:const InputDecoration(labelText:'الخامة'),items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)upd(()=>selected=v);}),
Text('رصيد المصدر: '+qtyText(balance(selected,source.name))+' '+selected.unit),Text('رصيد الوجهة: '+qtyText(balance(selected,target.name))+' '+selected.unit),field(q, translateEnglish('الكمية للتحويل'),numeric:true),field(note, translateEnglish('ملاحظات / رقم الإذن'))
])),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:(){
final amount=double.tryParse(q.text.trim().replaceAll(',','.'));
if(source==target){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('اختار مخزنين مختلفين'))));return;}
if(amount==null||amount<=0||amount>balance(selected,source.name)){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('الكمية غير صحيحة أو رصيد المصدر غير كافٍ'))));return;}
final stamp=DateTime.now();final transferNo='TR-${stamp.year}${stamp.month.toString().padLeft(2,'0')}${stamp.day.toString().padLeft(2,'0')}-${stamp.hour.toString().padLeft(2,'0')}${stamp.minute.toString().padLeft(2,'0')}${stamp.second.toString().padLeft(2,'0')}';
final memo=(note.text.trim().isEmpty?'':note.text.trim()+' | ')+'رقم التحويل: '+transferNo;
setBalance(selected,source.name,balance(selected,source.name)-amount);setBalance(selected,target.name,balance(selected,target.name)+amount);
movements.add(Movement(selected.n,'تحويل صادر',amount,'إلى '+target.name+' | '+memo,stamp,source.name,'',selected.cost));movements.add(Movement(selected.n,'تحويل وارد',amount,'من '+source.name+' | '+memo,stamp,target.name,'',selected.cost));
addAudit('تحويل','مخزون',selected.n+' • '+qtyText(amount)+' '+selected.unit+' • '+source.name+' ← '+target.name+' • '+transferNo);save();setState(()=>{});Navigator.pop(dc);
},child:Text(translateEnglish('اعتماد التحويل')))])));
}
Future<void> editMovement(Movement m)async{
  if(m.ref.isNotEmpty||!['استلام','صرف','صرف للموقع'].contains(m.type))return;
  if(!current.admin&&!current.warehouses.contains(m.warehouse))return;
  final qty=TextEditingController(text:qtyText(m.qty));
  final note=TextEditingController(text:m.note);
  await showDialog<void>(context:context,builder:(dc)=>AlertDialog(title:Text(translateEnglish('تعديل حركة المخزون')),content:Column(mainAxisSize:MainAxisSize.min,children:[Text(translateEnglish(m.type)+' • '+m.item+' • '+m.warehouse),field(qty,translateEnglish('الكمية'),numeric:true),field(note,translateEnglish('ملاحظات'))]),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()async{final amount=double.tryParse(qty.text.trim().replaceAll(',','.'));if(amount==null||amount<=0){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أدخل كمية صحيحة'))));return;}final old=m.qty;final currentBalance=balance(items.firstWhere((i)=>i.n==m.item),m.warehouse);final next=m.type=='استلام'?currentBalance+(amount-old):currentBalance+(old-amount);if(next< -0.000001){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('الرصيد غير كافٍ لتعديل الحركة'))));return;}final item=items.firstWhere((i)=>i.n==m.item);setBalance(item,m.warehouse,next<0?0:next);m.qty=amount;m.note=note.text.trim();addAudit('تعديل','حركة مخزون',m.item+' • '+m.type+' • '+qtyText(old)+' → '+qtyText(amount)+' • '+m.warehouse);await save();if(mounted)setState((){});if(dc.mounted)Navigator.pop(dc);},child:Text(translateEnglish('حفظ التعديلات')))]));
}
Future<void> deleteMovement(Movement m)async{
  if(m.ref.isNotEmpty||!['استلام','صرف','صرف للموقع'].contains(m.type))return;
  if(!current.admin&&!current.warehouses.contains(m.warehouse))return;
  final confirm=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:Text(translateEnglish('حذف حركة المخزون')),content:Text(translateEnglish('سيتم عكس أثر الحركة على الرصيد. هل تريد الحذف؟')+'\n'+m.item+' • '+m.type+' • '+qtyText(m.qty)+' • '+m.warehouse),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:Text(translateEnglish('حذف')))]));
  if(confirm!=true)return;
  final item=items.firstWhere((i)=>i.n==m.item);
  final currentBalance=balance(item,m.warehouse);
  final next=m.type=='استلام'?currentBalance-m.qty:currentBalance+m.qty;
  if(next< -0.000001){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('لا يمكن حذف الاستلام لأن الرصيد الحالي لا يسمح بعكس الحركة'))));return;}
  setBalance(item,m.warehouse,next<0?0:next);
  movements.remove(m);
  addAudit('حذف','حركة مخزون',m.item+' • '+m.type+' • '+qtyText(m.qty)+' • '+m.warehouse);
  await save();if(mounted)setState((){});
}
Future<void> movementHistoryDialog() async {
  final list = visibleMovements.reversed.toList();
  await showDialog(
    context: context,
    builder: (dc) => AlertDialog(
      title: Text(translateEnglish('سجل حركات المخزون')),
      content: SizedBox(
        width: 450,
        height: 450,
        child: list.isEmpty
          ? Center(child: Text(translateEnglish('لا توجد حركات')))
          : ListView(
              children: list.map((m) => ListTile(
                leading: Icon(
                  m.type.contains('وارد') || m.type == 'استلام'
                    ? Icons.arrow_downward
                    : m.type.contains('صادر') || m.type == 'صرف'
                      ? Icons.arrow_upward
                      : Icons.swap_horiz,
                ),
                title: Text(translateEnglish('${m.item} • ${m.type} • ${qtyText(m.qty)}')),
                subtitle: Text('${m.warehouse} | ${m.date.toString()}${m.note.isEmpty ? '' : '\n'+m.note}'),
                trailing: m.ref.isEmpty&&['استلام','صرف','صرف للموقع'].contains(m.type) ? Wrap(spacing:0,children:[IconButton(tooltip:translateEnglish('تعديل'),icon:const Icon(Icons.edit_outlined),onPressed:()=>editMovement(m)),IconButton(tooltip:translateEnglish('حذف'),icon:const Icon(Icons.delete_outline,color:Colors.red),onPressed:()=>deleteMovement(m))]) : null,
              )).toList(),
            ),
      ),
      actions: [
        TextButton(onPressed: () async { Navigator.pop(dc); final result = await CloudConnection.checkDatabase(); if (mounted) showDialog<void>(context: context, builder: (x) => AlertDialog(title: Text(translateEnglish('فحص الكلاود')), content: Text(result), actions: [TextButton(onPressed: () => Navigator.pop(x), child: Text(translateEnglish('تمام')))])); }, child: Text(translateEnglish('فحص الاتصال'))),
        TextButton(onPressed: () => Navigator.pop(dc), child: Text(translateEnglish('إغلاق'))),
      ],
    ),
  );
}
Future<void> recipeDialog()async{if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('أضف خامات أولاً'))));return;}Item selected=items.first;String meal='إفطار';final q=TextEditingController(text:'1');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:Text(translateEnglish('تحديد استهلاك الخامة لكل وجبة')),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)set(()=>selected=v);}),DropdownButtonFormField<String>(value:meal,items:['إفطار','غداء','عشاء'].map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),onChanged:(v){if(v!=null)set(()=>meal=v);}),field(q, translateEnglish('الكمية لكل وجبة بوحدة المخزون'),numeric:true),Text(translateEnglish('عند تسجيل الوجبات سيتم خصم الاستهلاك تلقائيًا.'))]),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:(){final qty=double.tryParse(q.text.trim().replaceAll(',', '.'));if(qty==null||qty<=0)return;final old=recipes.where((r)=>r.item==selected.n&&r.meal==meal);if(old.isNotEmpty){old.first.qty=qty;}else{recipes.add(Recipe(selected.n,meal,qty));}save();setState(()=>{});Navigator.pop(x);},child:Text(translateEnglish('حفظ الوصفة')))])));}
Future<void> exportImportTemplate() async {
 try {
  final book=Excel.createExcel();
  book.rename('Sheet1','بيانات المخزون');
  final sheet=book['بيانات المخزون'];
  sheet.appendRow([TextCellValue('كود الصنف'),TextCellValue('اسم الصنف'),TextCellValue('وحدة القياس'),TextCellValue('المخزن'),TextCellValue('الرصيد الافتتاحي'),TextCellValue('حد التنبيه'),TextCellValue('متوسط التكلفة'),TextCellValue('ملاحظات')]);
  sheet.appendRow([TextCellValue('ITM-001'),TextCellValue('مثال: أرز'),TextCellValue('كجم'),TextCellValue('المخزن الرئيسي'),DoubleCellValue(0),DoubleCellValue(5),DoubleCellValue(0),TextCellValue('مثال - احذف الصف قبل الاستيراد')]);
  final guide=book['تعليمات'];
  guide.appendRow([TextCellValue('StockPro Business - قالب استيراد المخزون')]);
  guide.appendRow([TextCellValue('1'),TextCellValue('الأعمدة الأساسية المطلوبة: كود الصنف، اسم الصنف، وحدة القياس، المخزن. ويمكن استخدام الأسماء الإنجليزية البديلة أيضاً.')]);
  guide.appendRow([TextCellValue('2'),TextCellValue('كل صنف يجب أن يكون له كود فريد واسم ووحدة قياس ومخزن موجود داخل البرنامج.')]);
  guide.appendRow([TextCellValue('3'),TextCellValue('الأعمدة الاختيارية: الرصيد الافتتاحي، حد التنبيه، متوسط التكلفة، ملاحظات. إذا تركتها فارغة فسيتم اعتبار الأرقام صفرًا.')]);
  guide.appendRow([TextCellValue('4'),TextCellValue('استخدم أسماء المخازن المطابقة تماماً للمخازن المسجلة. يمكنك استخدام المخزن الرئيسي.')]);
  guide.appendRow([TextCellValue('5'),TextCellValue('احذف صف المثال، ثم احفظ الملف بصيغة Excel .xlsx واستورده من شاشة المخزون.')]);
  final encoded=book.encode();
  if(encoded==null)throw Exception('تعذر إنشاء قالب Excel');
  final name='StockPro_Import_Template.xlsx';
  final saved=await FilePicker.platform.saveFile(fileName:name,bytes:Uint8List.fromList(encoded),type:FileType.custom,allowedExtensions:['xlsx']);
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(saved==null?'تم إلغاء حفظ القالب':'تم حفظ قالب استيراد المخزون بنجاح')));
 }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('فشل إنشاء القالب: $e'))));}
}
Future<void> importExcel() async {
 try {
  final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['xlsx'],withData:true);
  if(picked==null)return;
  final bytes=picked.files.single.bytes;
  if(bytes==null||bytes.isEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('لم أستطع قراءة الملف. احفظه بصيغة Excel .xlsx وحاول مرة أخرى.'))));return;}
  // Normalize OpenXML workbook relationship targets before decoding.
  // Some valid XLSX writers (including OpenPyXL) use absolute /xl/... targets.
  // excel 4.0.6 prefixes every target with "xl/" and crashes on those paths.
  List<int> excelBytes = bytes;
  final sourceArchive = zip.ZipDecoder().decodeBytes(bytes);
  final relationships = sourceArchive.findFile('xl/_rels/workbook.xml.rels');
  if (relationships != null) {
   final originalXml = utf8.decode(relationships.content);
   final normalizedXml = originalXml.replaceAllMapped(
    RegExp(r'''(Target\s*=\s*["'])([^"']+)(["'])'''),
    (match) {
     var target = match.group(2)!;
     if (target.startsWith('/xl/')) {
      target = target.substring(4);
     } else if (target.startsWith('xl/')) {
      target = target.substring(3);
     }
     return '${match.group(1)}$target${match.group(3)}';
    },
   );
   if (normalizedXml != originalXml) {
    final normalizedArchive = zip.Archive();
    for (final part in sourceArchive.files) {
     if (!part.isFile) continue;
     final content = part.name == 'xl/_rels/workbook.xml.rels'
      ? Uint8List.fromList(utf8.encode(normalizedXml))
      : part.content;
     normalizedArchive.addFile(zip.ArchiveFile(part.name, content.length, content));
    }
    final normalizedBytes = zip.ZipEncoder().encode(normalizedArchive);
    if (normalizedBytes == null || normalizedBytes.isEmpty) {
     throw const FormatException('تعذر تجهيز ملف Excel للاستيراد');
    }
    excelBytes = normalizedBytes;
   }
  }
  final book=Excel.decodeBytes(excelBytes);
  const aliases=<String,List<String>>{
   'ItemCode':['itemcode','code','item code','كودالصنف','كودالخامة','الكود'],
   'ItemName':['itemname','name','item name','اسمالصنف','اسمالخامة','الصنف'],
   'Unit':['unit','uom','وحدةالقياس','الوحدة'],
   'Warehouse':['warehouse','storename','المخزن','اسمالمخزن'],
   'OpeningBalance':['openingbalance','opening balance','openingstock','الرصيدالافتتاحي','رصيداولالمدة','رصيداولالمده'],
   'MinimumStock':['minimumstock','minimum stock','minstock','الحدالادنى','حدالتنبيه'],
   'AverageCost':['averagecost','average cost','unitcost','متوسطالتكلفة','تكلفةالوحدة'],
   'Notes':['notes','ملاحظات']
  };
  String norm(String value)=>value.toLowerCase().replaceAll('\uFEFF','').replaceAll(RegExp(r'[\s_\-]+'),'').trim();
  final required=['ItemCode','ItemName','Unit','Warehouse'];
  String chosenSheet='';
  int headerRow=-1;
  Map<String,int> columns={};
  List<List<Data?>>? dataRows;
  for(final entry in book.tables.entries){
   final rows=entry.value.rows;
   for(var r=0;r<rows.length&&r<25;r++){
    final headers=rows[r].map((cell)=>cell?.value?.toString()??'').toList();
    final found=<String,int>{};
    for(final canonical in aliases.keys){
     final names=aliases[canonical]!.map(norm).toSet();
     final index=headers.indexWhere((h)=>names.contains(norm(h)));
     if(index>=0)found[canonical]=index;
    }
    if(required.every(found.containsKey)){
     chosenSheet=entry.key;headerRow=r;columns=found;dataRows=rows;break;
    }
   }
   if(dataRows!=null)break;
  }
  if(dataRows==null){
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('لم أجد ورقة بيانات بعناوين صحيحة. استخدم قالب StockPro وتأكد من وجود أعمدة كود الصنف واسم الصنف ووحدة القياس والمخزن.'))));
   return;
  }
  String number(String value){
   var raw=value.trim().replaceAll('٬','').replaceAll('٫','.').replaceAll(' ','');
   if(raw.contains(',')&&raw.contains('.')){raw=raw.replaceAll(',','');}
   else if(raw.contains(',')){raw=raw.replaceAll(',','.');}
   return raw;
  }
  int imported=0,skipped=0;
  final unknownWarehouses=<String>{};
  final duplicateCodes=<String>{};
  for(final row in dataRows!.skip(headerRow+1)){
   String val(String key){
    final index=columns[key];
    if(index==null||index>=row.length)return '';
    return row[index]?.value?.toString().trim()??'';
   }
   final code=val('ItemCode'),name=val('ItemName'),unit=val('Unit'),warehouseName=val('Warehouse');
   final note=val('Notes').toLowerCase();
   if([code,name,unit,warehouseName].every((v)=>v.isEmpty))continue;
   if(note.contains('delete this example row')||note.contains('مثال')){skipped++;continue;}
   if(code.isEmpty||name.isEmpty||unit.isEmpty||warehouseName.isEmpty){skipped++;continue;}
   if(items.any((item)=>item.code.trim().toLowerCase()==code.toLowerCase())){
    skipped++;duplicateCodes.add(code);continue;
   }
   final wanted=norm(warehouseName);
   Warehouse? warehouse;
   for(final candidate in visibleWarehouses){
    if(norm(candidate.name)==wanted){warehouse=candidate;break;}
   }
   if(warehouse==null&&['mainwarehouse','المخزنالرئيسي','المخزنالرئيسى'].contains(wanted)){
    for(final candidate in visibleWarehouses){if(candidate.main){warehouse=candidate;break;}}
   }
   if(warehouse==null){skipped++;unknownWarehouses.add(warehouseName);continue;}
   double numVal(String key)=>double.tryParse(number(val(key)))??0;
   final item=Item(name,code,unit,numVal('AverageCost'),numVal('OpeningBalance'),numVal('MinimumStock'));
   items.add(item);
   stockBalances.putIfAbsent(warehouse.name,()=>{});
   stockBalances[warehouse.name]![item.n]=item.q;
   if(warehouse.main)item.q=stockBalances[warehouse.name]![item.n]??0;
   if(item.q>0)movements.add(Movement(item.n,'رصيد افتتاحي',item.q,'Import Excel',DateTime.now(),warehouse.name,'',item.cost));
   imported++;
  }
  if(imported>0)addAudit('استيراد Excel','خامات',imported.toString()+' خامة جديدة من '+chosenSheet+' • تم تخطي '+skipped.toString());
  await save();
  if(mounted)setState((){});
  final details=<String>['تم استيراد $imported خامة','تم تخطي $skipped'];
  if(unknownWarehouses.isNotEmpty)details.add('مخازن غير مطابقة: '+unknownWarehouses.take(3).join('، '));
  if(duplicateCodes.isNotEmpty)details.add('أكواد مكررة: '+duplicateCodes.take(3).join('، '));
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:const Duration(seconds:8),content:Text(details.join(' | '))));
 }catch(e){
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(seconds:8),content:Text(translateEnglish('فشل الاستيراد: $e'))));
 }
}
Future<void> itemDialog({Item? existing})async{
  final n=TextEditingController(text:existing?.n??''),code=TextEditingController(text:existing?.code??''),u=TextEditingController(text:existing?.unit??'كجم'),cost=TextEditingController(text:(existing?.cost??0).toString()),q=TextEditingController(text:(existing?.q??0).toString()),min=TextEditingController(text:(existing?.min??0).toString());
  await showDialog(context:context,builder:(x)=>AlertDialog(title:Text(existing==null?'إضافة خامة':'تعديل بيانات الخامة'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n, translateEnglish('اسم المادة')),field(code, translateEnglish('كود/باركود')),field(u, translateEnglish('وحدة القياس')),field(cost, translateEnglish('تكلفة الوحدة'),numeric:true),if(existing==null)field(q, translateEnglish('الرصيد الافتتاحي بالمخزن الرئيسي'),numeric:true),field(min, translateEnglish('حد التنبيه'),numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:(){
    final name=n.text.trim(),itemCode=code.text.trim(),unit=u.text.trim();final unitCost=double.tryParse(cost.text.trim().replaceAll(',','.')),opening=double.tryParse(q.text.trim().replaceAll(',','.'))??0,minimum=double.tryParse(min.text.trim().replaceAll(',','.'));
    if(name.isEmpty||unit.isEmpty||unitCost==null||unitCost<0||minimum==null||minimum<0||(existing==null&&opening<0)){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('راجع البيانات وأدخل أرقامًا صحيحة غير سالبة'))));return;}
    if(items.any((i)=>i!=existing&&i.n.toLowerCase()==name.toLowerCase())){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('اسم الخامة موجود بالفعل'))));return;}
    if(itemCode.isNotEmpty&&items.any((i)=>i!=existing&&i.code.trim().toLowerCase()==itemCode.toLowerCase())){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('الكود مستخدم بالفعل'))));return;}
    if(existing==null){itemAdd(Item(name,itemCode,unit,unitCost,opening,minimum));addAudit('إضافة','خامة',name+' • كود '+itemCode);}
    else{
      final oldName=existing.n;
      if(oldName!=name){for(final balances in stockBalances.values){if(balances.containsKey(oldName)){final value=balances.remove(oldName)!;balances[name]=value;}}for(final movement in movements){if(movement.item==oldName)movement.item=name;}for(final recipe in recipes){if(recipe.item==oldName)recipe.item=name;}}
      existing.n=name;existing.code=itemCode;existing.unit=unit;existing.cost=unitCost;existing.min=minimum;existing.q=balance(existing,mainWarehouse.name);
      addAudit('تعديل','خامة',oldName+' ← '+name+' • الكود '+itemCode+' • تكلفة '+cash(unitCost));
    }
    save();setState((){});Navigator.pop(x);
  },child:Text(translateEnglish('حفظ')))]));}
Future<void> deleteItem(Item item)async{
  final hasMovement=movements.any((m)=>m.item==item.n),hasRecipe=recipes.any((r)=>r.item==item.n);
  if(hasMovement||hasRecipe){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('لا يمكن حذف خامة مرتبطة بحركات مخزون أو وصفات. يمكنك تعديل بياناتها بدلاً من ذلك.'))));return;}
  final ok=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:Text(translateEnglish('حذف خامة')),content:Text('حذف '+item.n+'؟ سيتم حذف أرصدتها من المخازن.'),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:Text(translateEnglish('حذف')))]));
  if(ok!=true)return;items.remove(item);for(final balances in stockBalances.values){balances.remove(item.n);}addAudit('حذف','خامة',item.n);await save();if(mounted)setState((){});
}
String cash(double n)=>n.toStringAsFixed(2)+' ج.م';
String qtyText(double n){
  var value=n.toStringAsFixed(3);
  while(value.contains('.')&&value.endsWith('0')){value=value.substring(0,value.length-1);}
  if(value.endsWith('.')){value=value.substring(0,value.length-1);}
  return value;
}
Widget field(TextEditingController x,String label,{bool numeric=false,bool decimal=true})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:x,keyboardType:numeric?TextInputType.numberWithOptions(decimal:decimal):TextInputType.text,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));

Future<void> exportBackup() async {
  try {
    final p=await SharedPreferences.getInstance();
    const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','users','activeUser','auditLogs','expenses','wasteAlertThreshold','wasteAlertReviews'];
    final data=<String,dynamic>{'app':'StockPro','schema':1,'createdAt':DateTime.now().toIso8601String()};
    for(final key in keys){data[key]=p.get(key);}
    final bytes=Uint8List.fromList(utf8.encode(jsonEncode(data)));
    final name='StockPro_Backup_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2,'0')}${DateTime.now().day.toString().padLeft(2,'0')}.json';
    final path=await FilePicker.platform.saveFile(fileName:name,bytes:bytes,type:FileType.custom,allowedExtensions:['json']);
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(path==null?'تم إلغاء حفظ النسخة':'تم إنشاء النسخة الاحتياطية بنجاح')));
  }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('فشل إنشاء النسخة الاحتياطية: $e'))));}
}
Future<void> restoreBackup() async {
  if(!current.admin){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('الاستعادة متاحة للمدير فقط'))));return;}
  try{
    final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['json'],withData:true);
    if(picked==null)return;
    final bytes=picked.files.single.bytes;
    if(bytes==null||bytes.isEmpty)throw Exception('الملف فارغ أو غير قابل للقراءة');
    final parsed=jsonDecode(utf8.decode(bytes));
    if(parsed is! Map||parsed['app']!='StockPro'||parsed['schema']!=1)throw Exception('الملف ليس نسخة StockPro معتمدة');
    const keys=['sites','days','items','movements','recipes','warehouses','stockBalances','users','activeUser','auditLogs','expenses','wasteAlertThreshold','wasteAlertReviews'];
    for(final key in ['sites','days','items','movements','recipes','warehouses','users','auditLogs','expenses']){
      if(parsed[key]!=null&&parsed[key] is! List)throw Exception('بيانات غير سليمة في $key');
    }
    if(parsed['stockBalances']!=null&&parsed['stockBalances'] is! Map)throw Exception('أرصدة المخازن غير سليمة');
    if(parsed['wasteAlertReviews']!=null&&parsed['wasteAlertReviews'] is! Map)throw Exception('مراجعات تنبيهات الهالك غير سليمة');
    final confirm=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:Text(translateEnglish('استعادة نسخة احتياطية')),content:Text('سيتم استبدال البيانات الحالية بالنسخة من ${parsed['createdAt']??'تاريخ غير معروف'}. يفضل تصدير نسخة من بياناتك الحالية أولاً.'),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:Text(translateEnglish('إلغاء'))),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:Text(translateEnglish('استعادة')))]));
    if(confirm!=true)return;
    final p=await SharedPreferences.getInstance();
    for(final key in keys){if(parsed.containsKey(key)){final value=parsed[key];if(value is String)await p.setString(key,value);else await p.setString(key,jsonEncode(value));}}
    if(!mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(translateEnglish('تمت الاستعادة. سيتم إعادة فتح البرنامج بالبيانات المستعادة.'))));
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=>const Hub()),(route)=>false);
  }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(seconds:8),content:Text(translateEnglish('تعذر استعادة النسخة: $e'))));}
}

Future<void> stockCountDialog() async {
  if (items.isEmpty || visibleWarehouses.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('لا توجد خامات أو مخازن متاحة'))));
    return;
  }
  Warehouse wh = visibleWarehouses.first;
  Item item = items.first;
  final actual = TextEditingController(text: qtyText(balance(item, wh.name)));
  final note = TextEditingController();
  await showDialog(
    context: context,
    builder: (dc) => StatefulBuilder(
      builder: (dc, upd) => AlertDialog(
        title: Text(translateEnglish('جرد وتسوية مخزنية')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<Warehouse>(
              value: wh, decoration: InputDecoration(labelText: translateEnglish('المخزن')),
              items: visibleWarehouses.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
              onChanged: (v) { if (v != null) { upd(() => wh = v); actual.text = qtyText(balance(item, wh.name)); } },
            ),
            DropdownButtonFormField<Item>(
              value: item, decoration: InputDecoration(labelText: translateEnglish('الخامة')),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.n))).toList(),
              onChanged: (v) { if (v != null) { upd(() => item = v); actual.text = qtyText(balance(item, wh.name)); } },
            ),
            Text(translateEnglish('الرصيد الدفتري: ${qtyText(balance(item, wh.name))} ${item.unit}')),
            field(actual, translateEnglish('الرصيد الفعلي بعد الجرد'), numeric: true),
            field(note, translateEnglish('ملاحظات / رقم محضر الجرد')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: Text(translateEnglish('إلغاء'))),
          FilledButton(onPressed: () {
            final counted = double.tryParse(actual.text.trim().replaceAll(',', '.'));
            if (counted == null || counted < 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('أدخل رصيدًا فعليًا صحيحًا'))));
              return;
            }
            final book = balance(item, wh.name), delta = counted - book;
            if (delta.abs() < 0.000001) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translateEnglish('الرصيد الفعلي مطابق للرصيد الدفتري'))));
              return;
            }
            final type = delta > 0 ? 'تسوية زيادة' : 'تسوية عجز';
            setBalance(item, wh.name, counted);
            movements.add(Movement(item.n, type, delta.abs(),
              (note.text.trim().isEmpty ? '' : note.text.trim() + ' • ') + 'دفترى ' + qtyText(book) + ' / فعلي ' + qtyText(counted),
              DateTime.now(), wh.name));
            addAudit('جرد', 'تسوية مخزون', item.n + ' • ' + wh.name + ' • ' + type + ' ' + qtyText(delta.abs()) + ' ' + item.unit);
            save(); setState(() {}); Navigator.pop(dc);
          }, child: Text(translateEnglish('اعتماد الجرد'))),
        ],
      ),
    ),
  );
}

}
