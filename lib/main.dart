import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
void main()=>runApp(const App());
class MonierBrand extends StatelessWidget{final double size;final bool light;const MonierBrand({super.key,this.size=70,this.light=false});@override Widget build(BuildContext c)=>Column(mainAxisSize:MainAxisSize.min,children:[SizedBox(width:size,height:size,child:Stack(alignment:Alignment.center,children:[Text('M',style:TextStyle(fontSize:size*.82,fontWeight:FontWeight.w900,color:light?Colors.white:const Color(0xff092d50))),Positioned(right:size*.12,bottom:size*.12,child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:[for(int i=1;i<=3;i++)Container(width:size*.09,height:size*.12*i,margin:EdgeInsets.only(left:size*.025),decoration:BoxDecoration(color:const Color(0xff21a447),borderRadius:BorderRadius.circular(size*.02)))]))])),Text('MONIER',style:TextStyle(fontSize:size*.23,fontWeight:FontWeight.w900,letterSpacing:size*.055,color:light?Colors.white:const Color(0xff092d50))),]);}

class App extends StatelessWidget{const App({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:Colors.teal)),home:const AnimatedSplash());}
class LoginScreen extends StatefulWidget{const LoginScreen({super.key});@override State<LoginScreen> createState()=>LoginState();}
class LoginState extends State<LoginScreen>{
  final pin=TextEditingController();List<AppUser> users=[];AppUser? selected;bool loading=true;
  @override void initState(){super.initState();loadUsers();}
  Future<void> loadUsers()async{final p=await SharedPreferences.getInstance();try{users=(jsonDecode(p.getString('users')??'[]') as List).map((x)=>AppUser(x['n'],x['pin']??'',x['admin']??false,Set<String>.from(x['p']??AppUser.modules),Set<String>.from(x['sites']??[]),Set<String>.from(x['warehouses']??[]))).toList();}catch(_){}if(users.isEmpty){users=[AppUser('المدير','',true,Set<String>.from(AppUser.modules))];await p.setString('users',jsonEncode(users.map((u)=>u.j()).toList()));}selected=users.first;setState(()=>loading=false);}
  Future<void> enter()async{if(selected==null)return;if(pin.text!=selected!.pin){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('PIN غير صحيح')));return;}final p=await SharedPreferences.getInstance();await p.setString('activeUser',selected!.name);if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Hub()));}
  @override
  Widget build(BuildContext c) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MonierBrand(size: 82),
                const Text('StockPro', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xff092d50))),
                const SizedBox(height: 22),
                DropdownButtonFormField<AppUser>(
                  value: selected,
                  decoration: const InputDecoration(labelText: 'المستخدم', border: OutlineInputBorder()),
                  items: users.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                  onChanged: (u) => setState(() => selected = u),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder()),
                  onSubmitted: (_) => enter(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: enter, child: const Text('دخول')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
                  Text('StockPro', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Inventory • Operations • Better Control', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
class Movement{String item,type,note,warehouse,ref;double qty;DateTime date;Movement(this.item,this.type,this.qty,this.note,this.date,[this.warehouse='',this.ref='']);Map j()=>{'i':item,'t':type,'q':qty,'n':note,'d':date.toIso8601String(),'w':warehouse,'ref':ref};}
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
class HState extends State<Hub>{int tab=0;bool ready=false;DateTime reportFrom=DateTime(DateTime.now().year,DateTime.now().month,1);DateTime reportTo=DateTime.now();final sites=<Site>[];final days=<Day>[];final items=<Item>[];final movements=<Movement>[];final recipes=<Recipe>[];final warehouses=<Warehouse>[];final users=<AppUser>[];final auditLogs=<AuditEntry>[];final expenses=<Expense>[];final stockBalances=<String,Map<String,double>>{};String activeUser='المدير';AppUser get current=>users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{}));List<Site> get visibleSites=>current.admin?sites:sites.where((s)=>current.sites.contains(s.name)).toList();List<Warehouse> get visibleWarehouses=>current.admin?warehouses:warehouses.where((w)=>current.warehouses.contains(w.name)).toList();List<Day> get visibleDays=>current.admin?days:days.where((x)=>current.sites.contains(x.site)).toList();List<Movement> get visibleMovements=>current.admin?movements:movements.where((m)=>current.warehouses.contains(m.warehouse)).toList();List<Item> get visibleItems=>current.admin||visibleWarehouses.isNotEmpty?items:[];double visibleBalance(Item item)=>visibleWarehouses.fold(0.0,(sum,w)=>sum+balance(item,w.name));double get visibleStock=>visibleItems.fold(0.0,(sum,item)=>sum+visibleBalance(item)*item.cost);int get visibleLowStockCount=>visibleItems.where((item)=>visibleBalance(item)<=item.min).length;
Future<void> load()async{final p=await SharedPreferences.getInstance();try{sites.addAll((jsonDecode(p.getString('sites')??'[]') as List).map((x)=>Site(x['n'],x['c'],(x['b'] as num).toDouble(),(x['l'] as num).toDouble(),(x['d'] as num).toDouble())));days.addAll((jsonDecode(p.getString('days')??'[]') as List).map((x)=>Day(x['s'],DateTime.parse(x['t']),x['b'],x['l'],x['d'],x['e'],id:x['id']??'')));items.addAll((jsonDecode(p.getString('items')??'[]') as List).map((x)=>Item(x['n'],x['c'],x['u'],(x['cost'] as num).toDouble(),(x['q'] as num).toDouble(),(x['min'] as num).toDouble())));movements.addAll((jsonDecode(p.getString('movements')??'[]') as List).map((x)=>Movement(x['i'],x['t'],(x['q'] as num).toDouble(),x['n'],DateTime.parse(x['d']),x['w']??'')));recipes.addAll((jsonDecode(p.getString('recipes')??'[]') as List).map((x)=>Recipe(x['i'],x['m'],(x['q'] as num).toDouble())));warehouses.addAll((jsonDecode(p.getString('warehouses')??'[]') as List).map((x)=>Warehouse(x['n'],x['s']??'',x['m']??'',x['main']??false)));users.addAll((jsonDecode(p.getString('users')??'[]') as List).map((x)=>AppUser(x['n'],x['pin']??'',x['admin']??false,Set<String>.from(x['p']??AppUser.modules),Set<String>.from(x['sites']??[]),Set<String>.from(x['warehouses']??[]))));
auditLogs.addAll((jsonDecode(p.getString('auditLogs')??'[]') as List).map((x)=>AuditEntry.fromMap(x)));expenses.addAll((jsonDecode(p.getString('expenses')??'[]') as List).map((x)=>Expense.fromMap(x)));activeUser=p.getString('activeUser')??'المدير';
if(users.isEmpty){users.add(AppUser('المدير','',true,Set<String>.from(AppUser.modules)));}
if(!users.any((u)=>u.name==activeUser))activeUser=users.first.name;
if(warehouses.isEmpty){warehouses.add(Warehouse('المخزن الرئيسي','كل الشركة','',true));}final raw=jsonDecode(p.getString('stockBalances')??'{}');if(raw is Map){raw.forEach((wh,v){if(v is Map)stockBalances[wh.toString()]=v.map((k,val)=>MapEntry(k.toString(),(val as num).toDouble()));});}final main=warehouses.firstWhere((w)=>w.main,orElse:()=>warehouses.first);stockBalances.putIfAbsent(main.name,()=>{});for(final item in items){stockBalances[main.name]!.putIfAbsent(item.n,()=>item.q);item.q=stockBalances[main.name]![item.n]??0;}}catch(_){if(users.isEmpty)users.add(AppUser('المدير','',true,Set<String>.from(AppUser.modules)));}setState(()=>ready=true);}
Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('sites',jsonEncode(sites.map((x)=>x.j()).toList()));await p.setString('days',jsonEncode(days.map((x)=>x.j()).toList()));await p.setString('items',jsonEncode(items.map((x)=>x.j()).toList()));await p.setString('movements',jsonEncode(movements.map((x)=>x.j()).toList()));await p.setString('recipes',jsonEncode(recipes.map((x)=>x.j()).toList()));await p.setString('warehouses',jsonEncode(warehouses.map((x)=>x.j()).toList()));await p.setString('stockBalances',jsonEncode(stockBalances));await p.setString('users',jsonEncode(users.map((x)=>x.j()).toList()));await p.setString('activeUser',activeUser);await p.setString('auditLogs',jsonEncode(auditLogs.map((x)=>x.j()).toList()));await p.setString('expenses',jsonEncode(expenses.map((x)=>x.j()).toList()));}
void addAudit(String action,String entity,String details){auditLogs.insert(0,AuditEntry(activeUser,action,entity,details,DateTime.now()));if(auditLogs.length>1000)auditLogs.removeRange(1000,auditLogs.length);}
@override void initState(){super.initState();load();}
bool today(DateTime d){final n=DateTime.now();return d.year==n.year&&d.month==n.month&&d.day==n.day;}
double rev(Day x){final s=sites.where((z)=>z.name==x.site);return s.isEmpty?0:x.b*s.first.b+x.l*s.first.l+x.d*s.first.d;}
int get mealTotal=>days.where((x)=>today(x.date)).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e);
double get revToday=>days.where((x)=>today(x.date)).fold(0.0,(a,x)=>a+rev(x));
double get stock=>items.fold(0.0,(a,x)=>a+x.q*x.cost);
bool can(String module)=>users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).admin||users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).permissions.contains(module);void siteAdd(Site x){setState(()=>sites.add(x));save();}void dayAdd(Day x){setState(()=>days.add(x));save();}void itemAdd(Item x){stockBalances.putIfAbsent(mainWarehouse.name,()=>{});stockBalances[mainWarehouse.name]![x.n]=x.q;setState(()=>items.add(x));save();}Warehouse get mainWarehouse=>warehouses.firstWhere((w)=>w.main,orElse:()=>warehouses.first);double balance(Item item,String warehouse)=>stockBalances[warehouse]?[item.n]??0;void setBalance(Item item,String warehouse,double value){stockBalances.putIfAbsent(warehouse,()=>{});stockBalances[warehouse]![item.n]=value;if(warehouse==mainWarehouse.name)item.q=value;}
@override Widget build(BuildContext c){if(!ready)return const Scaffold(body:Center(child:CircularProgressIndicator()));final views=[dashboard(),sitePage(),dayPage(),itemPage(),reportPage(),warehousePage(),userPage(),expensePage()];final allowedTabs=[0,1,2,3,4,5,6,7].where((i)=>i==6?users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).admin:can(AppUser.modules[i])).toList();if(!allowedTabs.contains(tab))tab=allowedTabs.isEmpty?0:allowedTabs.first;final icons=[Icons.home,Icons.apartment,Icons.restaurant,Icons.inventory,Icons.analytics,Icons.warehouse,Icons.people,Icons.receipt_long];final labels=['الرئيسية','المواقع','الوجبات','المخزون','التقارير','المخازن','المستخدمون','المصروفات'];return Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Row(mainAxisSize:MainAxisSize.min,children:[MonierBrand(size:30),SizedBox(width:8),Text('StockPro | التغذية')])),body:views[tab],bottomNavigationBar:NavigationBar(selectedIndex:allowedTabs.indexOf(tab),onDestinationSelected:(i)=>setState(()=>tab=allowedTabs[i]),destinations:allowedTabs.map((i)=>NavigationDestination(icon:Icon(icons[i]),label:labels[i])).toList())));}
Future<void> expenseDialog({Expense? existing})async{
 if(visibleSites.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('سجل المواقع أولاً')));return;}
 final categories=['عمالة','نقل','إقامة','مصروفات الموقع','صيانة','أخرى'];
 Site chosen=visibleSites.firstWhere((x)=>x.name==existing?.site,orElse:()=>visibleSites.first);
 String category=categories.contains(existing?.category)?existing!.category:'أخرى';DateTime date=existing?.date??DateTime.now();
 final amount=TextEditingController(text:existing?.amount.toString()??'');final note=TextEditingController(text:existing?.note??'');
 await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,refresh)=>AlertDialog(title:Text(existing==null?'إضافة مصروف':'تعديل مصروف'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
 DropdownButtonFormField<Site>(value:chosen,decoration:const InputDecoration(labelText:'الموقع'),items:visibleSites.map((s)=>DropdownMenuItem(value:s,child:Text(s.name))).toList(),onChanged:(v){if(v!=null)refresh(()=>chosen=v);}),
 DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'نوع المصروف'),items:categories.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)refresh(()=>category=v);}),
 OutlinedButton.icon(onPressed:()async{final p=await showDatePicker(context:dc,initialDate:date,firstDate:DateTime(2020),lastDate:DateTime(2100));if(p!=null)refresh(()=>date=p);},icon:const Icon(Icons.date_range),label:Text('التاريخ: ${reportDateText(date)}')),
 field(amount,'المبلغ بالجنيه',numeric:true),field(note,'ملاحظات')
 ])),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),FilledButton(onPressed:(){
 final value=double.tryParse(amount.text.trim().replaceAll(',','.'))??0;if(value<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل مبلغ صحيح')));return;}
 if(existing==null){expenses.add(Expense(DateTime.now().microsecondsSinceEpoch.toString(),chosen.name,category,note.text.trim(),date,value));addAudit('إضافة','مصروف',chosen.name+' • '+category+' • '+cash(value));}
 else{existing.site=chosen.name;existing.category=category;existing.note=note.text.trim();existing.date=date;existing.amount=value;addAudit('تعديل','مصروف',chosen.name+' • '+category+' • '+cash(value));}
 save();setState((){});Navigator.pop(dc);
 },child:const Text('حفظ'))]));
}
Future<void> deleteExpense(Expense x)async{final ok=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:const Text('حذف المصروف'),content:Text('حذف مصروف ${cash(x.amount)} — ${x.site}؟'),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:const Text('حذف'))]));if(ok==true){expenses.remove(x);addAudit('حذف','مصروف',x.site+' • '+cash(x.amount));await save();if(mounted)setState((){});}}
Widget expensePage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('مصروفات المواقع',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:expenseDialog,icon:const Icon(Icons.add),label:const Text('مصروف جديد'))]),metric('إجمالي مصروفات المواقع',cash(expenses.where((x)=>current.admin||current.sites.contains(x.site)).fold<double>(0.0,(double a,Expense x)=>a+x.amount)),Icons.receipt_long),...expenses.where((x)=>current.admin||current.sites.contains(x.site)).toList().reversed.map((x)=>Card(child:ListTile(title:Text(x.site+' • '+x.category),subtitle:Text(reportDateText(x.date)+(x.note.isEmpty?'':'\\n'+x.note)),leading:const Icon(Icons.money_off),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(cash(x.amount)),IconButton(icon:const Icon(Icons.edit),onPressed:()=>expenseDialog(existing:x)),IconButton(icon:const Icon(Icons.delete_outline,color:Colors.red),onPressed:()=>deleteExpense(x))]))))]);
Widget userPage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('المستخدمون والصلاحيات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:userDialog,icon:const Icon(Icons.person_add),label:const Text('إضافة مستخدم')),if(current.admin)OutlinedButton.icon(onPressed:auditLogDialog,icon:const Icon(Icons.history),label:const Text('سجل التدقيق'))]),Card(child:ListTile(leading:const Icon(Icons.account_circle),title:const Text('المستخدم الحالي'),subtitle:Text(activeUser),trailing:DropdownButton<String>(value:activeUser,items:users.map((u)=>DropdownMenuItem(value:u.name,child:Text(u.name))).toList(),onChanged:(v){if(v!=null){setState(()=>activeUser=v);save();}}))),const Card(child:ListTile(title:Text('تنبيه أمان'),subtitle:Text('الصلاحيات محفوظة على نفس الجهاز. اختيار المستخدم هنا للتجربة فقط وليس تسجيل دخول آمنًا؛ سنضيف شاشة دخول ورقم PIN في خطوة تالية.'))),...users.map((u)=>Card(child:ListTile(leading:Icon(u.admin?Icons.admin_panel_settings:Icons.person),title:Text(u.name),subtitle:Text(u.admin?'مدير — صلاحيات كاملة':'صلاحيات: '+u.permissions.join('، ')),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>userDialog(existing:u)))))]); 
Future<void> userDialog({AppUser? existing})async{
  final name=TextEditingController(text:existing?.name??'');final pin=TextEditingController(text:existing?.pin??'');bool admin=existing?.admin??false;
  final perms=Set<String>.from(existing?.permissions??{});final siteScope=Set<String>.from(existing?.sites??{});final warehouseScope=Set<String>.from(existing?.warehouses??{});
  await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(
    title:Text(existing==null?'إضافة مستخدم':'تعديل المستخدم'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      field(name,'اسم المستخدم'),field(pin,'رقم PIN (إجباري)',numeric:true,decimal:false),
      CheckboxListTile(value:admin,title:const Text('مدير — صلاحيات كاملة'),onChanged:(v)=>set(()=>admin=v??false)),
      const Divider(),...AppUser.modules.map((m)=>CheckboxListTile(dense:true,value:perms.contains(m),title:Text('السماح بـ $m'),onChanged:(v)=>set(()=>v==true?perms.add(m):perms.remove(m)))),
      const Divider(),const Text('المواقع المسموح بها'),...sites.map((site)=>CheckboxListTile(dense:true,value:siteScope.contains(site.name),title:Text(site.name),onChanged:(v)=>set(()=>v==true?siteScope.add(site.name):siteScope.remove(site.name)))),
      const Text('المخازن المسموح بها'),...warehouses.map((wh)=>CheckboxListTile(dense:true,value:warehouseScope.contains(wh.name),title:Text(wh.name),onChanged:(v)=>set(()=>v==true?warehouseScope.add(wh.name):warehouseScope.remove(wh.name))))
    ])),
    actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){
      if(name.text.trim().isEmpty||pin.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('اسم المستخدم والـ PIN مطلوبان')));return;}
      if(existing==null){if(users.any((u)=>u.name==name.text.trim())){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('اسم المستخدم موجود بالفعل')));return;}users.add(AppUser(name.text.trim(),pin.text.trim(),admin,Set<String>.from(perms),Set<String>.from(siteScope),Set<String>.from(warehouseScope)));}
      else{existing.name=name.text.trim();existing.pin=pin.text.trim();existing.admin=admin;existing.permissions=Set<String>.from(perms);existing.sites=Set<String>.from(siteScope);existing.warehouses=Set<String>.from(warehouseScope);}
      addAudit(existing==null?'إضافة':'تعديل','مستخدم',name.text.trim());save();setState((){});Navigator.pop(x);
    },child:const Text('حفظ'))])));
}
Future<void> auditLogDialog()async{final search=TextEditingController();await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,refresh){final q=search.text.trim().toLowerCase();final list=auditLogs.where((x)=>q.isEmpty||[x.user,x.action,x.entity,x.details].join(' ').toLowerCase().contains(q)).toList();return AlertDialog(title:const Text('سجل التدقيق'),content:SizedBox(width:480,height:480,child:Column(children:[TextField(controller:search,decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'بحث بالمستخدم أو العملية أو التفاصيل'),onChanged:(_)=>refresh((){})),const SizedBox(height:8),Expanded(child:list.isEmpty?const Center(child:Text('لا توجد سجلات')):ListView.builder(itemCount:list.length,itemBuilder:(c,i){final x=list[i];return ListTile(dense:true,leading:const Icon(Icons.history),title:Text('${x.action} • ${x.entity}'),subtitle:Text('${x.user} | ${x.date.toLocal()}\\n${x.details}'));}))])),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إغلاق'))]);}));}
Widget metric(String title,String val,IconData icon)=>Card(child:ListTile(leading:Icon(icon,color:Colors.teal),title:Text(title),subtitle:Text(val)));
Widget dashboard()=>ListView(padding:const EdgeInsets.all(14),children:[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Colors.teal.shade900,borderRadius:BorderRadius.circular(16)),child:const Text('إدارة مواقع التغذية والعقود\nالوجبات • المخزون • الإيرادات',style:TextStyle(color:Colors.white,fontSize:21))),metric('إيراد اليوم',cash(days.where((x)=>today(x.date)&&(current.admin||current.sites.contains(x.site))).fold(0.0,(a,x)=>a+rev(x))),Icons.payments),metric('وجبات اليوم',days.where((x)=>today(x.date)&&(current.admin||current.sites.contains(x.site))).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e).toString(),Icons.restaurant),metric('عدد المواقع',visibleSites.length.toString(),Icons.apartment),metric('عدد الخامات',visibleItems.length.toString(),Icons.inventory),metric('خامات وصلت حد التنبيه',visibleLowStockCount.toString(),Icons.warning),metric('قيمة المخزون',cash(visibleStock),Icons.warehouse),Wrap(spacing:8,children:[if(can('المواقع'))FilledButton(onPressed:()=>siteDialog(),child:const Text('إضافة موقع')),if(can('الوجبات'))FilledButton(onPressed:()=>dayDialog(),child:const Text('تسجيل وجبات')),if(can('المخزون')&&(current.admin||visibleWarehouses.any((w)=>w.main)))FilledButton(onPressed:()=>itemDialog(),child:const Text('إضافة خامة'))])]);

Widget warehousePage() => ListView(padding:const EdgeInsets.all(12),children:[
Row(children:[const Expanded(child:Text('إدارة المخازن',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:warehouseDialog,icon:const Icon(Icons.add),label:const Text('مخزن جديد'))]),
Wrap(spacing:6,children:[FilledButton.icon(onPressed:transferDialog,icon:const Icon(Icons.swap_horiz),label:const Text('تحويل مخزني')),OutlinedButton.icon(onPressed:movementHistoryDialog,icon:const Icon(Icons.history),label:const Text('سجل الحركات'))]),
const Card(child:ListTile(leading:Icon(Icons.info_outline),title:Text('رصيد مستقل لكل مخزن'),subtitle:Text('الاستلام والصرف والتحويلات تُسجل على المخزن المحدد.'))),
  ...visibleWarehouses.map((w)=>Card(child:ListTile(leading:Icon(w.main?Icons.warehouse:Icons.store,color:Colors.teal),title:Text(w.name),subtitle:Text((w.main?'مخزن رئيسي':'مخزن فرعي')+' • '+w.site+'\nقيمة الرصيد: '+cash(items.fold(0.0,(sum,it)=>sum+balance(it,w.name)*it.cost))),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>warehouseDialog(existing:w)))))
]);
Widget sitePage()=>listPage('المواقع والعقود',visibleSites.map((s)=>Card(child:ListTile(title:Text(s.name),subtitle:Text(s.client+'\nإفطار '+cash(s.b)+' / غداء '+cash(s.l)+' / عشاء '+cash(s.d))))).toList(),siteDialog,'إضافة موقع');
Widget dayPage()=>listPage('سجل الوجبات',visibleDays.reversed.map((x)=>Card(child:ListTile(title:Text(x.site),subtitle:Text(x.date.day.toString()+'/'+x.date.month.toString()+' | إفطار '+x.b.toString()+' غداء '+x.l.toString()+' عشاء '+x.d.toString()+' إضافي '+x.e.toString()),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(cash(rev(x))),IconButton(tooltip:'تعديل',icon:const Icon(Icons.edit),onPressed:()=>dayDialog(existing:x)),IconButton(tooltip:'حذف',icon:const Icon(Icons.delete_outline,color:Colors.red),onPressed:()=>deleteDay(x))])))).toList(),dayDialog,'تسجيل وجبات');
Widget itemPage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('المخزون والخامات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),if(current.admin||visibleWarehouses.any((w)=>w.main))FilledButton(onPressed:itemDialog,child:const Text('إضافة خامة'))]),if(visibleWarehouses.isNotEmpty)Wrap(spacing:8,children:[OutlinedButton.icon(onPressed:importExcel,icon:const Icon(Icons.upload_file),label:const Text('Import Excel')),OutlinedButton.icon(onPressed:()=>movementDialog('استلام'),icon:const Icon(Icons.add_box),label:const Text('استلام خامات')),OutlinedButton.icon(onPressed:()=>movementDialog('صرف'),icon:const Icon(Icons.remove_circle),label:const Text('صرف خامات')),OutlinedButton.icon(onPressed:recipeDialog,icon:const Icon(Icons.menu_book),label:const Text('وصفات الوجبات'))]),if(visibleItems.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('لا توجد خامات أو لا توجد مخازن مسموح بها'))),...visibleItems.map((x)=>Card(child:ListTile(title:Text(x.n),subtitle:Text(x.code+' | '+x.unit+' | حد التنبيه '+qtyText(x.min)+'\\n'+visibleWarehouses.map((w)=>w.name+': '+qtyText(balance(x,w.name))).join(' | ')),trailing:Text(qtyText(visibleWarehouses.fold(0.0,(sum,w)=>sum+balance(x,w.name)))+' '+x.unit+'\\n'+cash(visibleWarehouses.fold(0.0,(sum,w)=>sum+balance(x,w.name))*x.cost))))),const Padding(padding:EdgeInsets.only(top:12),child:Text('آخر حركات المخزون',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),if(visibleMovements.isEmpty)const Text('لا توجد حركات مسجلة'),...visibleMovements.reversed.take(30).map((m)=>Card(child:ListTile(leading:Icon(m.type=='استلام'?Icons.arrow_downward:Icons.arrow_upward,color:m.type=='استلام'?Colors.green:Colors.orange),title:Text(m.item+' — '+m.type+' '+qtyText(m.qty)),subtitle:Text(m.date.day.toString()+'/'+m.date.month.toString()+'/'+m.date.year.toString()+(m.note.isEmpty?'':'\\n'+m.note)))))]);
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
  for(final entry in periodDays){breakfast+=entry.b;lunch+=entry.l;dinner+=entry.d;extra+=entry.e;revenue+=rev(entry);rawCost+=mealCost(entry);}
  summary.appendRow([TextCellValue('إفطار'),IntCellValue(breakfast)]);
  summary.appendRow([TextCellValue('غداء'),IntCellValue(lunch)]);
  summary.appendRow([TextCellValue('عشاء'),IntCellValue(dinner)]);
  summary.appendRow([TextCellValue('وجبات إضافية'),IntCellValue(extra)]);
  summary.appendRow([TextCellValue('إجمالي الوجبات'),IntCellValue(breakfast+lunch+dinner+extra)]);
  summary.appendRow([TextCellValue('إيراد الوجبات المسعّرة'),DoubleCellValue(revenue)]);
  summary.appendRow([TextCellValue('تكلفة الخامات حسب الوصفات'),DoubleCellValue(rawCost)]);
  summary.appendRow([TextCellValue('الفائض بعد تكلفة الخامات'),DoubleCellValue(revenue-rawCost)]);summary.appendRow([TextCellValue('مصروفات المواقع'),DoubleCellValue(expensesTotal)]);summary.appendRow([TextCellValue('صافي الربح بعد المصروفات'),DoubleCellValue(revenue-rawCost-expensesTotal)]);final expenseSheet=book['المصروفات'];expenseSheet.appendRow([TextCellValue('التاريخ'),TextCellValue('الموقع'),TextCellValue('التصنيف'),TextCellValue('المبلغ'),TextCellValue('ملاحظات')]);for(final x in periodExpenses){expenseSheet.appendRow([TextCellValue(reportDateText(x.date)),TextCellValue(x.site),TextCellValue(x.category),DoubleCellValue(x.amount),TextCellValue(x.note)]);}
  final bySite=book['تفصيل المواقع'];
  bySite.appendRow([TextCellValue('الموقع'),TextCellValue('إفطار'),TextCellValue('غداء'),TextCellValue('عشاء'),TextCellValue('إضافية'),TextCellValue('الإجمالي'),TextCellValue('الإيراد'),TextCellValue('تكلفة الخامات'),TextCellValue('الفائض'),TextCellValue('مصروفات'),TextCellValue('صافي الربح')]);
  for(final site in visibleSites){
   int b=0,l=0,d=0,e=0;double amount=0,cost=0;
   for(final entry in periodDays){if(entry.site==site.name){b+=entry.b;l+=entry.l;d+=entry.d;e+=entry.e;amount+=rev(entry);cost+=mealCost(entry);}}
   final siteExpenses=periodExpenses.where((x)=>x.site==site.name).fold<double>(0.0,(double sum,Expense x)=>sum+x.amount);bySite.appendRow([TextCellValue(site.name),IntCellValue(b),IntCellValue(l),IntCellValue(d),IntCellValue(e),IntCellValue(b+l+d+e),DoubleCellValue(amount),DoubleCellValue(cost),DoubleCellValue(amount-cost),DoubleCellValue(siteExpenses),DoubleCellValue(amount-cost-siteExpenses)]);
  }
  final daily=book['تفصيل التسجيلات'];
  daily.appendRow([TextCellValue('التاريخ'),TextCellValue('الموقع'),TextCellValue('إفطار'),TextCellValue('غداء'),TextCellValue('عشاء'),TextCellValue('إضافية'),TextCellValue('الإجمالي'),TextCellValue('الإيراد'),TextCellValue('تكلفة الخامات'),TextCellValue('الفائض')]);
  final ordered=List<Day>.from(periodDays)..sort((a,b)=>a.date.compareTo(b.date));
  for(final entry in ordered){final amount=rev(entry),cost=mealCost(entry);daily.appendRow([TextCellValue(reportDateText(entry.date)),TextCellValue(entry.site),IntCellValue(entry.b),IntCellValue(entry.l),IntCellValue(entry.d),IntCellValue(entry.e),IntCellValue(entry.b+entry.l+entry.d+entry.e),DoubleCellValue(amount),DoubleCellValue(cost),DoubleCellValue(amount-cost)]);}
  final encoded=book.encode();
  if(encoded==null)throw Exception('تعذر إنشاء ملف Excel');
  final fileName='StockPro_Report_${from.year}${from.month.toString().padLeft(2,'0')}${from.day.toString().padLeft(2,'0')}_to_${to.year}${to.month.toString().padLeft(2,'0')}${to.day.toString().padLeft(2,'0')}.xlsx';
  final saved=await FilePicker.platform.saveFile(fileName:fileName,bytes:Uint8List.fromList(encoded),type:FileType.custom,allowedExtensions:['xlsx']);
  if(!mounted)return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(saved==null?'تم إلغاء حفظ التقرير':'تم تصدير التقرير بنجاح')));
 }catch(e){
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('فشل تصدير التقرير: $e')));
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
    revenue+=rev(entry);rawCost+=mealCost(entry);
  }
  final allMeals=breakfast+lunch+dinner+extra;
  final rows=<Widget>[
    const Text('تقرير الوجبات والإيرادات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('حدد فترة التقرير',style:TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      Wrap(spacing:8,runSpacing:8,children:[
        OutlinedButton.icon(onPressed:()=>pickReportDate(true),icon:const Icon(Icons.calendar_today),label:Text('من: ${reportDateText(from)}')),
        OutlinedButton.icon(onPressed:()=>pickReportDate(false),icon:const Icon(Icons.event),label:Text('إلى: ${reportDateText(to)}')),
        TextButton(onPressed:()=>setState((){reportFrom=DateTime(now.year,now.month,1);reportTo=DateTime(now.year,now.month,now.day);}),child:const Text('الشهر الحالي')),
        TextButton(onPressed:()=>setState((){reportTo=DateTime(now.year,now.month,now.day);reportFrom=DateTime(now.year,now.month,now.day).subtract(const Duration(days:29));}),child:const Text('آخر 30 يوم')),
      ]),
      Text('الفترة المختارة: ${reportDateText(from)} — ${reportDateText(to)}',style:const TextStyle(color:Colors.teal,fontWeight:FontWeight.w600)),
      const SizedBox(height:10),
      FilledButton.icon(onPressed:()=>exportReportExcel(periodDays,from,to),icon:const Icon(Icons.file_download),label:const Text('تصدير التقرير إلى Excel'),),
    ]))),
    Card(child:Padding(padding:const EdgeInsets.all(14),child:Wrap(spacing:8,runSpacing:8,children:[
      Chip(label:Text('إفطار: $breakfast')),
      Chip(label:Text('غداء: $lunch')),
      Chip(label:Text('عشاء: $dinner')),
      Chip(label:Text('إضافية: $extra')),
    ]))),
    metric('إجمالي الوجبات',allMeals.toString(),Icons.restaurant),
    metric('إيراد الوجبات المسعّرة',cash(revenue),Icons.payments),
    metric('تكلفة الخامات حسب الوصفات',cash(rawCost),Icons.calculate),
    metric('الفائض بعد تكلفة الخامات',cash(revenue-rawCost),Icons.trending_up),metric('مصروفات المواقع خلال الفترة',cash(expensesTotal),Icons.receipt_long),metric('صافي الربح بعد المصروفات',cash(revenue-rawCost-expensesTotal),Icons.account_balance),
    Card(child:ListTile(leading:const Icon(Icons.info_outline),title:const Text('ملاحظة محاسبية'),subtitle:Text('الوجبات الإضافية: $extra وجبة. لا تدخل في الإيراد أو تكلفة الوصفات حاليًا لعدم وجود سعر تعاقدي ووصفة محددة لها. الفائض المعروض لا يشمل العمالة أو النقل أو المصروفات التشغيلية.'))),
    const Padding(padding:EdgeInsets.only(top:12,bottom:6),child:Text('تفصيل الأداء حسب الموقع',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),
  ];
  for(final site in visibleSites){
    int b=0,l=0,d=0,e=0;double amount=0,cost=0;
    for(final entry in periodDays){
      if(entry.site==site.name){
        b+=entry.b;l+=entry.l;d+=entry.d;e+=entry.e;
        amount+=rev(entry);cost+=mealCost(entry);
      }
    }
    final count=b+l+d+e;
    rows.add(Card(child:ExpansionTile(
      leading:const Icon(Icons.apartment,color:Colors.teal),
      title:Text(site.name,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Text('$count وجبة • إيراد ${cash(amount)}'),
      children:[
        ListTile(dense:true,title:const Text('إفطار'),trailing:Text('$b وجبة × ${cash(site.b)} = ${cash(b*site.b)}')),
        ListTile(dense:true,title:const Text('غداء'),trailing:Text('$l وجبة × ${cash(site.l)} = ${cash(l*site.l)}')),
        ListTile(dense:true,title:const Text('عشاء'),trailing:Text('$d وجبة × ${cash(site.d)} = ${cash(d*site.d)}')),
        ListTile(dense:true,title:const Text('وجبات إضافية'),trailing:Text('$e وجبة • غير مسعّرة')),
        const Divider(),
        ListTile(dense:true,title:const Text('تكلفة الخامات'),trailing:Text(cash(cost))),
        ListTile(dense:true,title:const Text('الفائض بعد تكلفة الخامات'),trailing:Text(cash(amount-cost),style:const TextStyle(fontWeight:FontWeight.bold,color:Colors.teal))),
      ],
    )));
  }
  if(periodDays.isEmpty)rows.add(const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('لا توجد وجبات مسجلة خلال الفترة المختارة للمواقع المسموح بها.'))));
  return ListView(padding:const EdgeInsets.all(14),children:rows);
}
Widget listPage(String title,List<Widget> rows,VoidCallback add,String label)=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton(onPressed:add,child:Text(label))]),if(rows.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(20),child:Text('لا توجد بيانات بعد'))),...rows]);
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
            field(name, 'اسم المخزن'),
            DropdownButtonFormField<String>(
              value: selectedSite,
              decoration: const InputDecoration(labelText: 'الموقع / نطاق المخزن'),
              items: siteOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) { if (v != null) setDialogState(() => selectedSite = v); },
            ),
            field(manager, 'المسؤول'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('مخزن رئيسي'),
              value: isMain,
              onChanged: (v) => setDialogState(() => isMain = v ?? false),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب اسم المخزن')));
                return;
              }
              if (isMain && warehouses.any((w) => w.main && w != existing)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يوجد مخزن رئيسي بالفعل')));
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
            child: const Text('حفظ'),
          ),
        ],
      ),
    ),
  );
}
Future<void> siteDialog()async{final n=TextEditingController(),c=TextEditingController(),b=TextEditingController(text:'0'),l=TextEditingController(text:'0'),d=TextEditingController(text:'0');await showDialog(context:context,builder:(x)=>AlertDialog(title:const Text('عقد الموقع'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n,'اسم الموقع'),field(c,'العميل'),field(b,'سعر الإفطار',numeric:true),field(l,'سعر الغداء',numeric:true),field(d,'سعر العشاء',numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){if(n.text.trim().isEmpty)return;siteAdd(Site(n.text,c.text,double.tryParse(b.text)??0,double.tryParse(l.text)??0,double.tryParse(d.text)??0));addAudit('إضافة','موقع',n.text.trim()+' • '+c.text.trim());save();Navigator.pop(x);},child:const Text('حفظ'))]));}
Future<void> deleteDay(Day record)async{
  final linked=movements.where((m)=>m.ref.isNotEmpty&&m.ref==record.id).toList();
  if(record.id.isEmpty&&movements.any((m)=>m.type=='استهلاك وجبات')){
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لا يمكن حذف سجل قديم غير مرتبط بحركات الاستهلاك؛ حفاظاً على دقة أرصدة المخازن.')));
    return;
  }
  final ok=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:const Text('حذف سجل الوجبات'),content:Text('هل تريد حذف تسجيل وجبات موقع ${record.site}؟ سيتم إرجاع الخامات التي استهلكها هذا التسجيل إلى المخزن.'),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(dc,true),child:const Text('حذف'))]));
  if(ok!=true)return;
  for(final m in linked){final item=items.where((i)=>i.n==m.item);if(item.isNotEmpty)setBalance(item.first,m.warehouse,balance(item.first,m.warehouse)+m.qty);}
  movements.removeWhere((m)=>m.ref.isNotEmpty&&m.ref==record.id);
  days.remove(record);addAudit('حذف','تسجيل وجبات',record.site+' • '+record.date.toLocal().toString());
  await save();
  if(mounted)setState((){});
}
Future<void> dayDialog({Day? existing})async{
  if(visibleSites.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('سجل موقع وعقد أولاً')));return;}
  if(existing!=null&&existing.id.isEmpty&&movements.any((m)=>m.type=='استهلاك وجبات')){
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('هذا سجل قديم غير مرتبط بحركات الاستهلاك؛ لا يمكن تعديله بأمان. السجلات الجديدة تدعم التعديل والحذف.')));
    return;
  }
  Site chosen=visibleSites.firstWhere((s)=>s.name==existing?.site,orElse:()=>visibleSites.first);
  final b=TextEditingController(text:(existing?.b??0).toString()),l=TextEditingController(text:(existing?.l??0).toString()),d=TextEditingController(text:(existing?.d??0).toString()),e=TextEditingController(text:(existing?.e??0).toString());
  final linked=existing==null? <Movement>[]:movements.where((m)=>m.ref.isNotEmpty&&m.ref==existing.id).toList();
  await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:Text(existing==null?'تسجيل الوجبات اليومية':'تعديل تسجيل الوجبات'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    DropdownButtonFormField<Site>(value:chosen,items:visibleSites.map((site)=>DropdownMenuItem(value:site,child:Text(site.name))).toList(),onChanged:(v){if(v!=null)set(()=>chosen=v);}),
    field(b,'عدد الإفطار',numeric:true,decimal:false),field(l,'عدد الغداء',numeric:true,decimal:false),field(d,'عدد العشاء',numeric:true,decimal:false),field(e,'وجبات إضافية غير مسعرة',numeric:true,decimal:false),
    Text('أسعار العقد: '+cash(chosen.b)+' / '+cash(chosen.l)+' / '+cash(chosen.d))
  ])),actions:[
    TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),
    FilledButton(onPressed:(){
      final nb=int.tryParse(b.text)??-1,nl=int.tryParse(l.text)??-1,nd=int.tryParse(d.text)??-1,ne=int.tryParse(e.text)??-1;
      if([nb,nl,nd,ne].any((v)=>v<0)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل أعداداً صحيحة غير سالبة')));return;}
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
        for(final entry in need.entries){setBalance(entry.key,consumeWh.name,balance(entry.key,consumeWh.name)-entry.value);movements.add(Movement(entry.key.n,'استهلاك وجبات',entry.value,'موقع: '+chosen.name,DateTime.now(),consumeWh.name,record.id));}
      }else{
        movements.removeWhere((m)=>m.ref.isNotEmpty&&m.ref==existing.id);
        existing.site=chosen.name;existing.b=nb;existing.l=nl;existing.d=nd;existing.e=ne;
        for(final entry in need.entries){setBalance(entry.key,consumeWh.name,balance(entry.key,consumeWh.name)-entry.value);movements.add(Movement(entry.key.n,'استهلاك وجبات',entry.value,'موقع: '+chosen.name,DateTime.now(),consumeWh.name,existing.id));}
      }
      addAudit(existing==null?'إضافة':'تعديل','تسجيل وجبات',chosen.name+' • إفطار '+nb.toString()+' / غداء '+nl.toString()+' / عشاء '+nd.toString());save();setState((){});Navigator.pop(x);
    },child:Text(existing==null?'حفظ':'حفظ التعديلات'))
  ])));
}
Future<void> movementDialog(String type) async {
if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامة أولاً')));return;}
Item selected=items.first;if(visibleWarehouses.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لا يوجد مخزن مسموح لك بالتعامل معه')));return;}Warehouse wh=visibleWarehouses.first;final qty=TextEditingController(),note=TextEditingController();
await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,upd)=>AlertDialog(title:Text('$type خامات'),content:Column(mainAxisSize:MainAxisSize.min,children:[
DropdownButtonFormField<Warehouse>(value:wh,items:visibleWarehouses.map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null)upd(()=>wh=v);}),
DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)upd(()=>selected=v);}),
field(qty,'الكمية بوحدة '+selected.unit,numeric:true),field(note,'ملاحظات'),Text('الرصيد الحالي: '+qtyText(balance(selected,wh.name))+' '+selected.unit)
]),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),FilledButton(onPressed:(){
final amount=double.tryParse(qty.text.trim().replaceAll(',','.'));if(amount==null||amount<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل كمية صحيحة')));return;}
final current=balance(selected,wh.name);if(type=='صرف'&&amount>current){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('رصيد غير كافٍ بالمخزن')));return;}
setBalance(selected,wh.name,current+(type=='استلام'?amount:-amount));movements.add(Movement(selected.n,type,amount,note.text.trim(),DateTime.now(),wh.name));addAudit(type,'حركة مخزون',selected.n+' • '+qtyText(amount)+' '+selected.unit+' • '+wh.name+' • '+note.text.trim());save();setState(()=>{});Navigator.pop(dc);
},child:const Text('تأكيد'))])));
}
Future<void> transferDialog()async{
final available=visibleWarehouses;
if(available.length<2){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لازم يكون عندك مخزنان على الأقل لإجراء التحويل')));return;}
if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامة أولاً')));return;}
Warehouse source=available.firstWhere((w)=>w.main,orElse:()=>available.first);
Warehouse target=available.firstWhere((w)=>w!=source);
Item selected=items.first;final q=TextEditingController(),note=TextEditingController();
await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,upd)=>AlertDialog(title:const Text('إذن تحويل مخزني'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
DropdownButtonFormField<Warehouse>(value:source,decoration:const InputDecoration(labelText:'من المخزن'),items:available.map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null){upd(()=>source=v);if(target==source)upd(()=>target=available.firstWhere((w)=>w!=source));}}),
DropdownButtonFormField<Warehouse>(value:target,decoration:const InputDecoration(labelText:'إلى المخزن'),items:available.where((w)=>w!=source).map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null)upd(()=>target=v);}),
DropdownButtonFormField<Item>(value:selected,decoration:const InputDecoration(labelText:'الخامة'),items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)upd(()=>selected=v);}),
Text('رصيد المصدر: '+qtyText(balance(selected,source.name))+' '+selected.unit),Text('رصيد الوجهة: '+qtyText(balance(selected,target.name))+' '+selected.unit),field(q,'الكمية للتحويل',numeric:true),field(note,'ملاحظات / رقم الإذن')
])),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),FilledButton(onPressed:(){
final amount=double.tryParse(q.text.trim().replaceAll(',','.'));
if(source==target){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('اختار مخزنين مختلفين')));return;}
if(amount==null||amount<=0||amount>balance(selected,source.name)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('الكمية غير صحيحة أو رصيد المصدر غير كافٍ')));return;}
final stamp=DateTime.now();final transferNo='TR-${stamp.year}${stamp.month.toString().padLeft(2,'0')}${stamp.day.toString().padLeft(2,'0')}-${stamp.hour.toString().padLeft(2,'0')}${stamp.minute.toString().padLeft(2,'0')}${stamp.second.toString().padLeft(2,'0')}';
final memo=(note.text.trim().isEmpty?'':note.text.trim()+' | ')+'رقم التحويل: '+transferNo;
setBalance(selected,source.name,balance(selected,source.name)-amount);setBalance(selected,target.name,balance(selected,target.name)+amount);
movements.add(Movement(selected.n,'تحويل صادر',amount,'إلى '+target.name+' | '+memo,stamp,source.name));movements.add(Movement(selected.n,'تحويل وارد',amount,'من '+source.name+' | '+memo,stamp,target.name));
addAudit('تحويل','مخزون',selected.n+' • '+qtyText(amount)+' '+selected.unit+' • '+source.name+' ← '+target.name+' • '+transferNo);save();setState(()=>{});Navigator.pop(dc);
},child:const Text('اعتماد التحويل'))])));
}
Future<void> movementHistoryDialog() async {
  final list = visibleMovements.reversed.toList();
  await showDialog(
    context: context,
    builder: (dc) => AlertDialog(
      title: const Text('سجل حركات المخزون'),
      content: SizedBox(
        width: 450,
        height: 450,
        child: list.isEmpty
          ? const Center(child: Text('لا توجد حركات'))
          : ListView(
              children: list.map((m) => ListTile(
                leading: Icon(
                  m.type.contains('وارد') || m.type == 'استلام'
                    ? Icons.arrow_downward
                    : m.type.contains('صادر') || m.type == 'صرف'
                      ? Icons.arrow_upward
                      : Icons.swap_horiz,
                ),
                title: Text('${m.item} • ${m.type} • ${qtyText(m.qty)}'),
                subtitle: Text('${m.warehouse} | ${m.date.toString()}${m.note.isEmpty ? '' : '\\n'+m.note}'),
              )).toList(),
            ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc), child: const Text('إغلاق')),
      ],
    ),
  );
}
Future<void> recipeDialog()async{if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامات أولاً')));return;}Item selected=items.first;String meal='إفطار';final q=TextEditingController(text:'1');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:const Text('تحديد استهلاك الخامة لكل وجبة'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)set(()=>selected=v);}),DropdownButtonFormField<String>(value:meal,items:['إفطار','غداء','عشاء'].map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),onChanged:(v){if(v!=null)set(()=>meal=v);}),field(q,'الكمية لكل وجبة بوحدة المخزون',numeric:true),const Text('عند تسجيل الوجبات سيتم خصم الاستهلاك تلقائيًا.')]),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){final qty=double.tryParse(q.text.trim().replaceAll(',', '.'));if(qty==null||qty<=0)return;final old=recipes.where((r)=>r.item==selected.n&&r.meal==meal);if(old.isNotEmpty){old.first.qty=qty;}else{recipes.add(Recipe(selected.n,meal,qty));}save();setState(()=>{});Navigator.pop(x);},child:const Text('حفظ الوصفة'))])));}
Future<void> importExcel() async {
 try {
  final picked=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['xlsx'],withData:true);
  if(picked==null)return;
  final bytes=picked.files.single.bytes;
  if(bytes==null||bytes.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لم أستطع قراءة الملف. احفظه بصيغة Excel .xlsx وحاول مرة أخرى.')));return;}
  final book=Excel.decodeBytes(bytes);
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
   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('لم أجد ورقة بيانات بعناوين صحيحة. استخدم قالب StockPro ولا تغيّر الأعمدة الأساسية: ItemCode, ItemName, Unit, Warehouse.')));
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
   if(item.q>0)movements.add(Movement(item.n,'رصيد افتتاحي',item.q,'Import Excel',DateTime.now(),warehouse.name));
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
  if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:const Duration(seconds:8),content:Text('فشل الاستيراد: $e')));
 }
}
Future<void> itemDialog()async{final n=TextEditingController(),code=TextEditingController(),u=TextEditingController(text:'كجم'),cost=TextEditingController(text:'0'),q=TextEditingController(text:'0'),min=TextEditingController(text:'0');await showDialog(context:context,builder:(x)=>AlertDialog(title:const Text('بيانات الخامة'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n,'اسم المادة'),field(code,'كود/باركود'),field(u,'وحدة القياس'),field(cost,'تكلفة الوحدة',numeric:true),field(q,'الرصيد الحالي',numeric:true),field(min,'حد التنبيه',numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){if(n.text.trim().isEmpty)return;itemAdd(Item(n.text,code.text,u.text,double.tryParse(cost.text.trim().replaceAll(',', '.'))??0,double.tryParse(q.text.trim().replaceAll(',', '.'))??0,double.tryParse(min.text.trim().replaceAll(',', '.'))??0));addAudit('إضافة','خامة',n.text.trim()+' • كود '+code.text.trim());save();Navigator.pop(x);},child:const Text('حفظ'))]));}
}
String cash(double n)=>n.toStringAsFixed(2)+' ج.م';
String qtyText(double n){
  var value=n.toStringAsFixed(3);
  while(value.contains('.')&&value.endsWith('0')){value=value.substring(0,value.length-1);}
  if(value.endsWith('.')){value=value.substring(0,value.length-1);}
  return value;
}
Widget field(TextEditingController x,String label,{bool numeric=false,bool decimal=true})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:x,keyboardType:numeric?TextInputType.numberWithOptions(decimal:decimal):TextInputType.text,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder()))) Future<void> expenseDialog({Expense? existing}) async {
  if (visibleSites.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجل المواقع أولاً'))); return; }
  final categories=['عمالة','نقل','إقامة','مصروفات الموقع','صيانة','أخرى'];
  Site chosen=visibleSites.firstWhere((x)=>x.name==existing?.site,orElse:()=>visibleSites.first);
  String category=categories.contains(existing?.category)?existing!.category:'أخرى';
  DateTime date=existing?.date??DateTime.now();
  final amount=TextEditingController(text:existing?.amount.toString()??'');
  final note=TextEditingController(text:existing?.note??'');
  await showDialog<void>(context:context,builder:(dialogContext)=>StatefulBuilder(builder:(dialogContext,refresh)=>AlertDialog(
    title:Text(existing==null?'إضافة مصروف':'تعديل مصروف'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      DropdownButtonFormField<Site>(value:chosen,decoration:const InputDecoration(labelText:'الموقع'),items:visibleSites.map((s)=>DropdownMenuItem(value:s,child:Text(s.name))).toList(),onChanged:(v){if(v!=null)refresh(()=>chosen=v);}),
      DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'نوع المصروف'),items:categories.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v){if(v!=null)refresh(()=>category=v);}),
      OutlinedButton.icon(onPressed:()async{final picked=await showDatePicker(context:dialogContext,initialDate:date,firstDate:DateTime(2020),lastDate:DateTime(2100));if(picked!=null)refresh(()=>date=picked);},icon:const Icon(Icons.date_range),label:Text('التاريخ: ${reportDateText(date)}')),
      field(amount,'المبلغ بالجنيه',numeric:true),field(note,'ملاحظات')
    ])),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(dialogContext),child:const Text('إلغاء')),
      FilledButton(onPressed:(){
        final value=double.tryParse(amount.text.trim().replaceAll(',','.'))??0;
        if(value<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل مبلغ صحيح')));return;}
        if(existing==null){expenses.add(Expense(DateTime.now().microsecondsSinceEpoch.toString(),chosen.name,category,note.text.trim(),date,value));addAudit('إضافة','مصروف',chosen.name+' • '+category+' • '+cash(value));}
        else{existing.site=chosen.name;existing.category=category;existing.note=note.text.trim();existing.date=date;existing.amount=value;addAudit('تعديل','مصروف',chosen.name+' • '+category+' • '+cash(value));}
        save();setState((){});Navigator.pop(dialogContext);
      },child:const Text('حفظ'))
    ]
  )));
 }
;